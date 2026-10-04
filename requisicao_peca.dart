class RequisicaoPeca {
  final int? idRequisicaoPeca;
  int idOrdemServico;
  DateTime dataRequisicao;
  String? finalidade;

  RequisicaoPeca({
    this.idRequisicaoPeca,
    required this.idOrdemServico,
    required this.dataRequisicao,
    this.finalidade,
  });
}
