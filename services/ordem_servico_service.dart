import '../models/ordem_servico.dart';
import '../repositories/maquinario_repository_mysql.dart';
import '../repositories/ordem_servico_repository_mysql.dart';
import '../exceptions/maquinario_inativo_exception.dart';
import '../exceptions/horimetro_invalido_exception.dart';
import '../exceptions/regra_negocio_exception.dart';

/// Classe de serviço responsável por orquestrar a lógica das Ordens de Serviço e o estado das máquinas.
class OrdemServicoService {
  // Instância do repositório de OS
  final OrdemServicoRepositoryMysql _osRepository;
  // Instância do repositório de maquinário
  final MaquinarioRepositoryMysql _maquinarioRepository;

  /// Injeção de dependências via construtor
  OrdemServicoService(this._osRepository, this._maquinarioRepository);

  /// Regra de Negócio: Abertura de Ordem de Serviço com bloqueio do equipamento e validação de horímetro
  Future<OrdemServico> abrirOrdemServico({
    required int idMaquinario,
    required String tipo,
    required double horimetroInformado,
    String? observacao,
  }) async {
    // Passo 1: Verifica se o maquinário indicado existe na base de dados
    final maquinario = await _maquinarioRepository.buscarPorId(idMaquinario);
    if (maquinario == null) {
      throw RegraNegocioException('Maquinário com ID $idMaquinario não existe no cadastro.');
    }

    // Passo 2: Regra de Negócio - Apenas equipamentos 'Ativo' podem entrar em manutenção
    if (maquinario.status != 'Ativo') {
      throw MaquinarioInativoException(maquinario.descricao);
    }

    // Passo 3: Regra de Negócio - Valida a progressão do horímetro (impede regressão das horas rodadas)
    if (horimetroInformado < maquinario.horimetroAtual) {
      throw HorimetroInvalidoException(horimetroInformado, maquinario.horimetroAtual);
    }

    // Passo 4: Altera o estado da máquina para 'Em manutencao' e atualiza a leitura do horímetro
    maquinario.status = 'Em manutencao';
    maquinario.horimetroAtual = horimetroInformado;
    // Grava as alterações da máquina no MySQL
    await _maquinarioRepository.atualizar(maquinario);

    // Passo 5: Cria a nova Ordem de Serviço com os dados validados
    final novaOS = OrdemServico(
      idMaquinario: idMaquinario,
      tipo: tipo,
      status: 'Aberta',
      dataAbertura: DateTime.now(),
      horimetroMomento: horimetroInformado,
      observacao: observacao,
    );

    // Salva a nova OS no MySQL e devolve a entidade completa com ID
    return await _osRepository.salvar(novaOS);
  }

  /// Regra de Negócio: Finalização de Ordem de Serviço e libertação do equipamento
  Future<void> concluirOrdemServico(int idOrdemServico) async {
    // Passo 1: Localiza a OS no MySQL
    final os = await _osRepository.buscarPorId(idOrdemServico);
    if (os == null) {
      throw RegraNegocioException('Ordem de Serviço #$idOrdemServico não foi encontrada.');
    }

    // Impede que uma OS concluída seja alterada novamente
    if (os.status == 'Concluida') {
      throw RegraNegocioException('Esta Ordem de Serviço já foi concluída anteriormente.');
    }

    // Passo 2: Atualiza o status e marca a data de conclusão da OS
    os.status = 'Concluida';
    os.dataConclusao = DateTime.now();
    await _osRepository.atualizar(os);

    // Passo 3: Desbloqueia o maquinário associado, retornando o seu status para 'Ativo'
    final maquinario = await _maquinarioRepository.buscarPorId(os.idMaquinario);
    if (maquinario != null) {
      maquinario.status = 'Ativo';
      await _maquinarioRepository.atualizar(maquinario);
    }
  }
}