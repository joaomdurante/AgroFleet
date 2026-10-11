class Tecnico {
  final int? idTecnico;
  String nome;
  String? telefone;
  String? email;
  bool ativo;

  Tecnico({
    this.idTecnico,
    required this.nome,
    this.telefone,
    this.email,
    this.ativo = true,
  });
}
