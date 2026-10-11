import '../models/maquinario.dart';

class MaquinarioRepository {
  final List<Maquinario> _bancoEmMemoria = [];
  int _proximoId = 1;

  Maquinario salvar(Maquinario maquinario) {
    // Instancia um novo objeto preenchendo o ID gerado
    final novoMaquinario = Maquinario(
      idMaquinario: _proximoId++,
      idFazenda: maquinario.idFazenda,
      descricao: maquinario.descricao,
      modelo: maquinario.modelo,
      marca: maquinario.marca,
      anoFabricacao: maquinario.anoFabricacao,
      horimetroAtual: maquinario.horimetroAtual,
      dataAquisicao: maquinario.dataAquisicao,
      status: maquinario.status,
    );

    _bancoEmMemoria.add(novoMaquinario);
    return novoMaquinario; // Devolve a instância salva com ID
  }

  List<Maquinario> listarTodos() => List.unmodifiable(_bancoEmMemoria);

  Maquinario? buscarPorId(int id) {
    try {
      return _bancoEmMemoria.firstWhere((m) => m.idMaquinario == id);
    } catch (_) {
      return null;
    }
  }
}