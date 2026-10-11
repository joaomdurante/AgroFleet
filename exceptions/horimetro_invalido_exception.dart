import 'regra_negocio_exception.dart';

class HorimetroInvalidoException extends RegraNegocioException {
  HorimetroInvalidoException(double informado, double atual)
      : super('Horímetro informado ($informado h) é menor que o atual ($atual h).');
}