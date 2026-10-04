class AlocacaoTecnico {
  final int? idAlocacaoTecnico;
  int idOrdemServico;
  int idTecnico;
  DateTime dataAlocacao;
  String horaInicio;
  String horaFim;
  String funcao;

  AlocacaoTecnico({
    this.idAlocacaoTecnico,
    required this.idOrdemServico,
    required this.idTecnico,
    required this.dataAlocacao,
    required this.horaInicio,
    required this.horaFim,
    required this.funcao,
  });
}
