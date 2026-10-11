class Fazenda {
  final int? idFazenda;
  int idCliente;
  String nome;
  String? endereco;
  String? cidade;
  String? estado;

  Fazenda({
    this.idFazenda,
    required this.idCliente,
    required this.nome,
    this.endereco,
    this.cidade,
    this.estado,
  });
}
