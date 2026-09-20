import 'cliente.dart';
import 'maquinario.dart';

class OrdemServico {
  final int idOrdem;
  DateTime dataInicio;
  DateTime? dataFinal;
  String? tipo;
  String status;
  double? custo;
  Cliente cliente;
  Maquinario maquinario;

  OrdemServico({
    required this.idOrdem,
    required this.dataInicio,
    this.dataFinal,
    this.tipo,
    required this.status,
    this.custo,
    required this.cliente,
    required this.maquinario,
  });
}
