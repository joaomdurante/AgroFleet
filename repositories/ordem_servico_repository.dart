import '../models/ordem_servico.dart';

class OrdemServicoRepository {
  final List<OrdemServico> _bancoEmMemoria = [];
  int _proximoId = 1;

  OrdemServico salvar(OrdemServico os) {
    final novaOS = OrdemServico(
      idOrdemServico: _proximoId++,
      idMaquinario: os.idMaquinario,
      tipo: os.tipo,
      status: os.status,
      dataAbertura: os.dataAbertura,
      dataConclusao: os.dataConclusao,
      horimetroMomento: os.horimetroMomento,
      pendenciaAmbiental: os.pendenciaAmbiental,
      observacao: os.observacao,
    );

    _bancoEmMemoria.add(novaOS);
    return novaOS;
  }

  OrdemServico? buscarPorId(int id) {
    try {
      return _bancoEmMemoria.firstWhere((os) => os.idOrdemServico == id);
    } catch (_) {
      return null;
    }
  }

  void atualizar(OrdemServico osAtualizada) {
    final index = _bancoEmMemoria.indexWhere((os) => os.idOrdemServico == osAtualizada.idOrdemServico);
    if (index != -1) {
      _bancoEmMemoria[index] = osAtualizada;
    }
  }
}