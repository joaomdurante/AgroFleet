import 'regra_negocio_exception.dart';

class MaquinarioInativoException extends RegraNegocioException {
  MaquinarioInativoException(String descricao)
      : super('O equipamento "$descricao" não está com status ativo para manutenção.');
}