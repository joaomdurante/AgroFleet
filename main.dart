// Importa o modelo e o serviço
import 'models/destino_sustentavel.dart';
import 'services/destino_sustentavel_service.dart';

// O 'async' no main permite que a função principal aguarde a resposta das APIs
void main() async {
  print('=== TESTANDO VALIDAÇÃO REAL VIA BRASILAPI ===\n');

  // Instancia a classe de serviço para poder chamar seus métodos
  final service = DestinoSustentavelService();

  // Cria um objeto em memória com dados simulados
  var empresaEmpress = DestinoSustentavel(
    idDestinoSustentavel: 1,
    empresaLicenciada: 'Petrobras Distribuidora',
    cnpj: '33.000.167/0001-01', // CNPJ real da Petrobras
    licencaAmbiental: 'LAO-2026-9901',
  );

  // Bloco try-catch: tenta executar o fluxo feliz.
  // Se qualquer validação falhar (throw), cai imediatamente no bloco catch.
  try {
    await service.validarECadastrarDestino(
      empresaEmpress,
      DateTime(2027, 12, 31), // Licença válida
    );
  } catch (e) {
    // Imprime a mensagem tratada da exceção (sem quebrar o programa)
    print(e);
  }
}
