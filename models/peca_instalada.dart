class PecaInstalada {
  final int? idPecaInstalada;
  int idMaquinario;
  int idPeca;
  DateTime dataInstalacao;
  double horimetroInstalacao;
  int? idOrdemServicoInstalacao;
  DateTime? dataRemocao;
  double? horimetroRemocao;
  int? idOrdemServicoRemocao;
  String status; // 'Instalada', 'Removida'

  PecaInstalada({
    this.idPecaInstalada,
    required this.idMaquinario,
    required this.idPeca,
    required this.dataInstalacao,
    required this.horimetroInstalacao,
    this.idOrdemServicoInstalacao,
    this.dataRemocao,
    this.horimetroRemocao,
    this.idOrdemServicoRemocao,
    this.status = 'Instalada',
  });
}