import 'regra_negocio_exception.dart';

class MaquinarioInativoException extends RegraNegocioException {
  MaquinarioInativoException(String descricao)
      : super('Não é possível abrir OS - O maquinário "$descricao" não está ativo.');
}