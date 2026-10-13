class Tecnico {
  final int? idTecnico;
  String nome;
  String? telefone;
  String? email;
  bool ativo;
  double? valorHora;

  Tecnico({
    this.idTecnico,
    required this.nome,
    this.telefone,
    this.email,
    this.ativo = true,
    this.valorHora = 0,
  });
}
