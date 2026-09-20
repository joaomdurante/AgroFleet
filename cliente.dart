class Cliente {
  final int idCliente;
  String? nomeFazenda;
  String responsavel;
  String? telefone;

  Cliente({
    required this.idCliente,
    this.nomeFazenda,
    required this.responsavel,
    this.telefone,
  });
}
