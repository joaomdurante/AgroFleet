class RegraNegocioException implements Exception {
  final String mensagem;
  RegraNegocioException(this.mensagem);

  @override
  String toString() => mensagem;
}