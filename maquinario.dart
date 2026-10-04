class Maquinario {
  final int? idMaquinario;
  int idFazenda;
  String descricao;
  String? marca;
  String? modelo;
  int? anoFabricacao;
  double horimetroAtual = 0.0;
  DateTime? dataAquisicao;
  String status; // 'Ativo', 'Em Manutenção' ou 'Inativo'

  Maquinario({
    this.idMaquinario,
    required this.idFazenda,
    required this.descricao,
    this.marca,
    this.modelo,
    this.anoFabricacao,
    required this.horimetroAtual,
    this.dataAquisicao,
    this.status = 'Ativo',
  });
}
