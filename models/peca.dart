class Peca {
  final int? idPeca;
  String descricao;
  String tipo;
  double? vidaUtilHorimetro;
  String unidadeMedida; // 'UN', 'L', 'KG'

  Peca({
    this.idPeca,
    required this.descricao,
    required this.tipo,
    this.vidaUtilHorimetro,
    this.unidadeMedida = "UN",
  });
}
