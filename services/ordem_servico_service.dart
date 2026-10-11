import '../models/maquinario.dart';
import '../models/ordem_servico.dart';
import '../repositories/maquinario_repository.dart';
import '../repositories/ordem_servico_repository.dart';
import '../exceptions/maquinario_inativo_exception.dart';
import '../exceptions/horimetro_invalido_exception.dart';
import '../exceptions/regra_negocio_exception.dart';

class OrdemServicoService {
  // Injeção de Dependência: O serviço recebe os repositórios para manipular os dados
  final OrdemServicoRepository _osRepository;
  final MaquinarioRepository _maquinarioRepository;

  OrdemServicoService(this._osRepository, this._maquinarioRepository);

  /// Regra de Negócio: Abertura de Ordem de Serviço
  OrdemServico abrirOrdemServico({
    required int idMaquinario,
    required String tipo,
    required double horimetroInformado,
    String? observacao,
  }) {
    // 1. Busca o maquinário no repositório
    final maquinario = _maquinarioRepository.buscarPorId(idMaquinario);
    if (maquinario == null) {
      throw RegraNegocioException('Maquinário com ID $idMaquinario não existe no cadastro.');
    }

    // 2. Validação: Apenas máquinas 'Ativo' podem entrar em manutenção
    if (maquinario.status != 'Ativo') {
      throw MaquinarioInativoException(maquinario.descricao);
    }

    // 3. Validação: O horímetro informado não pode ser retroativo
    if (horimetroInformado < maquinario.horimetroAtual) {
      throw HorimetroInvalidoException(horimetroInformado, maquinario.horimetroAtual);
    }

    // 4. Atualiza o status do equipamento para bloquear novas ordens duplicadas
    maquinario.status = 'Em Manutenção';
    maquinario.horimetroAtual = horimetroInformado;

    // 5. Instancia a nova OS com status inicial 'Aberta'
    final novaOS = OrdemServico(
      idMaquinario: idMaquinario,
      tipo: tipo,
      status: 'Aberta',
      dataAbertura: DateTime.now(),
      horimetroMomento: horimetroInformado,
      observacao: observacao,
    );

    // 6. Salva e retorna a OS criada
    return _osRepository.salvar(novaOS);
  }

  /// Regra de Negócio: Conclusão de Ordem de Serviço
  void concluirOrdemServico(int idOrdemServico) {
    final os = _osRepository.buscarPorId(idOrdemServico);
    if (os == null) {
      throw RegraNegocioException('Ordem de Serviço #$idOrdemServico não foi encontrada.');
    }

    if (os.status == 'Concluída') {
      throw RegraNegocioException('Esta Ordem de Serviço já foi concluída anteriormente.');
    }

    // 1. Atualiza o estado da OS
    os.status = 'Concluída';
    os.dataConclusao = DateTime.now();
    _osRepository.atualizar(os);

    // 2. Libera o maquinário de volta para operação ('Ativo')
    final maquinario = _maquinarioRepository.buscarPorId(os.idMaquinario);
    if (maquinario != null) {
      maquinario.status = 'Ativo';
    }
  }
}