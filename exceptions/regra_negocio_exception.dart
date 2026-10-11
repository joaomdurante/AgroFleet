class RegraNegocioException implements Exception {
  final String mensagem;
  RegraNegocioException(this.mensagem);

  @override
  String toString() => 'Erro de Negócio: $mensagem';
}