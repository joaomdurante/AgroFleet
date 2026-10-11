import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/destino_sustentavel.dart';
import '../exceptions/licenca_ambiental_exception.dart';

class DestinoSustentavelService {
  /// Consulta o CNPJ na Receita Federal via BrasilAPI e valida a empresa
  Future<bool> validarCnpjNaReceita(String cnpj) async {
    // Remove pontuações (pontos, traços e barras)
    final cnpjLimpo = cnpj.replaceAll(RegExp(r'\D'), '');

    if (cnpjLimpo.length != 14) {
      throw LicencaAmbientalException('CNPJ inválido. Deve conter 14 dígitos.');
    }

    final url = Uri.parse('https://brasilapi.com.br/api/cnpj/v1/$cnpjLimpo');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final situacao = data['descricao_situacao_cadastral'] ?? '';

        if (situacao != 'ATIVA') {
          throw LicencaAmbientalException(
              'Situação Cadastral na Receita é "$situacao".');
        }

        return true; // CNPJ Existe e está Ativo
      } else if (response.statusCode == 404) {
        throw LicencaAmbientalException(
            'CNPJ não encontrado na base da Receita Federal.');
      } else {
        throw LicencaAmbientalException(
            'Falha ao consultar a BrasilAPI (Status ${response.statusCode}).');
      }
    } catch (e) {
      if (e is LicencaAmbientalException) rethrow;
      throw LicencaAmbientalException('Erro de conexão ao validar o CNPJ: $e');
    }
  }

  /// Valida todas as regras ambientais e cadastra a empresa
  Future<void> validarECadastrarDestino(
      DestinoSustentavel destino, DateTime dataValidadeLicenca) async {
    // 1. Validação de preenchimento do número da licença
    if (destino.licencaAmbiental.trim().isEmpty) {
      throw LicencaAmbientalException(
          'O número da licença ambiental é obrigatório.');
    }

    // 2. Validação da data de expiração da licença
    if (dataValidadeLicenca.isBefore(DateTime.now())) {
      throw LicencaAmbientalException(
          'A licença ambiental informada já está vencida.');
    }

    // 3. Validação Real via API Externa (BrasilAPI)
    print('Consultando CNPJ ${destino.cnpj} na Receita Federal...');
    await validarCnpjNaReceita(destino.cnpj);

    print(
        '✓ Empresa "${destino.empresaLicenciada}" aprovada e com CNPJ ativo!');
  }
}
