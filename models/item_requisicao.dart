class ItemRequisicao {
  final int? idItemRequisicao;
  int idRequisicaoPeca;
  int idPeca;
  double quantidade;
  double precoUnitario;

  ItemRequisicao({
    this.idItemRequisicao,
    required this.idRequisicaoPeca,
    required this.idPeca,
    required this.quantidade,
    required this.precoUnitario,
  });
}