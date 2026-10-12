import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/destino_sustentavel.dart';
import '../exceptions/licenca_ambiental_exception.dart';

/// Classe de serviço encarregada de integrar a API REST da Receita Federal (BrasilAPI) e validar licenças ambientais.
class DestinoSustentavelService {
  
  /// Consulta a situação cadastral do CNPJ em tempo real na Receita Federal via BrasilAPI
  Future<bool> validarCnpjNaReceita(String cnpj) async {
    // Sanitiza a string de CNPJ removendo pontuações
    final cnpjLimpo = cnpj.replaceAll(RegExp(r'\D'), '');

    // Valida o número correto de dígitos de um CNPJ
    if (cnpjLimpo.length != 14) {
      throw LicencaAmbientalException('CNPJ inválido. Deve conter 14 dígitos.');
    }

    // Monta o endpoint da requisição HTTP na BrasilAPI
    final url = Uri.parse('https://brasilapi.com.br/api/cnpj/v1/$cnpjLimpo');

    try {
      // Dispara a requisição GET
      final response = await http.get(url);

      // Tratamento para resposta com sucesso (Status 200 OK)
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final situacao = data['descricao_situacao_cadastral'] ?? '';

        // Exige que a situação cadastral na Receita seja ATIVA
        if (situacao != 'ATIVA') {
          throw LicencaAmbientalException('Situação Cadastral na Receita é "$situacao".');
        }

        return true; // Empresa ativa e regularizada
      } else if (response.statusCode == 404) {
        throw LicencaAmbientalException('CNPJ não encontrado na base da Receita Federal.');
      } else {
        throw LicencaAmbientalException('Falha ao consultar a BrasilAPI (Status ${response.statusCode}).');
      }
    } catch (e) {
      if (e is LicencaAmbientalException) rethrow;
      throw LicencaAmbientalException('Erro de conexão ao validar o CNPJ: $e');
    }
  }

  /// Valida e regista empresas recetoras de resíduos com base em normativas ambientais
  Future<void> validarECadastrarDestino(
      DestinoSustentavel destino, DateTime dataValidadeLicenca) async {
    // 1. Exige o preenchimento da licença ambiental
    if (destino.licencaAmbiental.trim().isEmpty) {
      throw LicencaAmbientalException('O número da licença ambiental é obrigatório.');
    }

    // 2. Valida a vigência da licença ambiental
    if (dataValidadeLicenca.isBefore(DateTime.now())) {
      throw LicencaAmbientalException('A licença ambiental informada já está vencida.');
    }

    // 3. Consulta a situação do CNPJ na Receita Federal
    print('Consultando CNPJ ${destino.cnpj} na Receita Federal...');
    await validarCnpjNaReceita(destino.cnpj);

    print('✓ Empresa "${destino.empresaLicenciada}" aprovada e com CNPJ ativo!');
  }
}