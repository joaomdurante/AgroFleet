class DestinoSustentavel {
  final int? idDestinoSustentavel;
  String empresaLicenciada;
  String cnpj;
  String licencaAmbiental;
  String? telefone;
  String? endereco;

  DestinoSustentavel({
    this.idDestinoSustentavel,
    required this.empresaLicenciada,
    required this.cnpj,
    required this.licencaAmbiental,
    this.telefone,
    this.endereco,
  });
}