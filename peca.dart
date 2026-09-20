class Peca {
  final int idpeca;
  int? estoque;
  double precoUnitario;
  String? descricao;
  String categoria;

  Peca({
    required this.idpeca,
    required this.categoria,
    this.descricao,
    this.estoque,
    required this.precoUnitario,
  });
}
