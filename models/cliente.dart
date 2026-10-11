class Cliente {
  final int? idCliente;
  String nome;
  String documento;
  String? telefone;
  String? email;

  Cliente({
    this.idCliente,
    required this.nome,
    required this.documento,
    this.telefone,
    this.email,
  });
}
