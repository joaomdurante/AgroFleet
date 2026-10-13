class Residuo {
  final int? idResiduo;
  int idOrdemServico;
  int? idDestinoSustentavel;
  String tipo; // 'Oleo', 'Filtro', 'Sucata', 'Outro'
  double quantidade;
  DateTime dataGeracao;
  String? observacao;
  String status; // 'Pendente', 'Descartado'

  Residuo({
    this.idResiduo,
    required this.idOrdemServico,
    this.idDestinoSustentavel,
    required this.tipo,
    required this.quantidade,
    required this.dataGeracao,
    this.observacao,
    this.status = 'Pendente',
  });
}