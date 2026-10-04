class Residuo {
  final int? idResiduo;
  int idOrdemServico;
  int idDestinoSustentavel;
  String tipo; // 'Óleo Lubrificante', 'Filtro Usado', 'Bateria'
  double quantidade;
  DateTime dataGeracao;
  String? observacao;

  Residuo({
    this.idResiduo,
    required this.idOrdemServico,
    required this.idDestinoSustentavel,
    required this.tipo,
    required this.quantidade,
    required this.dataGeracao,
    this.observacao,
  });
}