class OrdemServico {
  final int? idOrdemServico;
  int idMaquinario;
  String tipo; // "Preventiva" ou "Corretiva"
  String status; // "Aberta", "Em Andamento", "Concluída" ou "Cacelada";
  DateTime dataAbertura;
  DateTime? dataConclusao;
  double horimetroMomento;
  bool pendenciaAmbiental;
  String? observacao;

  OrdemServico({
    this.idOrdemServico,
    required this.idMaquinario,
    required this.tipo,
    this.status = "Aberta",
    required this.dataAbertura,
    this.dataConclusao,
    required this.horimetroMomento,
    this.pendenciaAmbiental = false,
    this.observacao,
  });
}
