import 'regra_negocio_exception.dart';

class HorimetroInvalidoException extends RegraNegocioException {
  HorimetroInvalidoException(double informado, double atual)
      : super('O horímetro informado ($informado h) não pode ser menor que o atual ($atual h).');
}