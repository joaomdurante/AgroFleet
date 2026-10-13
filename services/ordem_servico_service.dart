import '../models/ordem_servico.dart';
import '../repositories/maquinario_repository_mysql.dart';
import '../repositories/ordem_servico_repository_mysql.dart';
import '../exceptions/maquinario_inativo_exception.dart';
import '../exceptions/horimetro_invalido_exception.dart';
import '../exceptions/regra_negocio_exception.dart';

/// Classe de serviço responsável por orquestrar a lógica das Ordens de Serviço e o estado das máquinas.
class OrdemServicoService {
  final OrdemServicoRepositoryMysql _osRepository;
  final MaquinarioRepositoryMysql _maquinarioRepository;

  OrdemServicoService(this._osRepository, this._maquinarioRepository);

  /// Regra de Negócio: Abertura de Ordem de Serviço com bloqueio do equipamento e validação de horímetro
  Future<OrdemServico> abrirOrdemServico({
    required int idMaquinario,
    required String tipo,
    required double horimetroInformado,
    String? observacao,
  }) async {
    // 1. Normalização e validação prévia do Tipo de OS ('Preventiva' ou 'Corretiva')
    final tipoLimpo = tipo.trim().toLowerCase();
    final tipoFormatado = tipoLimpo == 'preventiva'
        ? 'Preventiva'
        : (tipoLimpo == 'corretiva' ? 'Corretiva' : null);

    if (tipoFormatado == null) {
      throw RegraNegocioException(
        'Tipo de serviço "$tipo" é inválido. Digite apenas "Preventiva" ou "Corretiva".',
      );
    }

    // 2. Verifica se o maquinário existe na base de dados
    final maquinario = await _maquinarioRepository.buscarPorId(idMaquinario);
    if (maquinario == null) {
      throw RegraNegocioException('Maquinário com ID #$idMaquinario não foi encontrado.');
    }

    // 3. Regra de Negócio: Apenas equipamentos com status "Ativo" podem entrar em manutenção
    if (maquinario.status != 'Ativo') {
      throw MaquinarioInativoException(maquinario.descricao);
    }

    // 4. Regra de Negócio: Valida a progressão do horímetro
    if (horimetroInformado < maquinario.horimetroAtual) {
      throw HorimetroInvalidoException(horimetroInformado, maquinario.horimetroAtual);
    }

    // 5. Cria e salva a nova Ordem de Serviço PRIMEIRO
    final novaOS = OrdemServico(
      idMaquinario: idMaquinario,
      tipo: tipoFormatado,
      status: 'Aberta',
      dataAbertura: DateTime.now(),
      horimetroMomento: horimetroInformado,
      observacao: observacao,
    );

    final osSalva = await _osRepository.salvar(novaOS);

    // 6. Atualiza o status do maquinário SOMENTE após a OS ser gravada com sucesso no MySQL
    maquinario.status = 'Em manutencao';
    maquinario.horimetroAtual = horimetroInformado;
    await _maquinarioRepository.atualizar(maquinario);

    return osSalva;
  }

  /// Regra de Negócio: Finalização de Ordem de Serviço e liberação do equipamento
  Future<void> concluirOrdemServico(int idOrdemServico) async {
    final os = await _osRepository.buscarPorId(idOrdemServico);
    if (os == null) {
      throw RegraNegocioException('Ordem de Serviço #$idOrdemServico não foi encontrada.');
    }

    if (os.status == 'Concluida') {
      throw RegraNegocioException('Esta Ordem de Serviço já foi concluída anteriormente.');
    }

    os.status = 'Concluida';
    os.dataConclusao = DateTime.now();
    await _osRepository.atualizar(os);

    final maquinario = await _maquinarioRepository.buscarPorId(os.idMaquinario);
    if (maquinario != null) {
      maquinario.status = 'Ativo';
      await _maquinarioRepository.atualizar(maquinario);
    }
  }
}