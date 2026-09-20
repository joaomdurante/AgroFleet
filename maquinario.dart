class Maquinario {
  final int idMaquinario;
  double horimetro = 0.0;
  String tipo;
  String? marca;
  String modelo;
  String status;

  Maquinario({
    required this.idMaquinario,
    required this.horimetro,
    required this.tipo,
    this.marca,
    required this.modelo,
    required this.status,
  });
}
