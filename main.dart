import 'models/cliente.dart';
import 'repositories/cliente_repository_mysql.dart';
import 'services/cliente_service.dart';

void main() async {
  print('=== TESTANDO PERSISTÊNCIA REAL NO MYSQL ===\n');

  final clienteRepoSql = ClienteRepositoryMysql();
  final clienteService = ClienteService(clienteRepoSql);

  final novoCliente = Cliente(
    nome: 'Fazenda  Teste 2',
    documento: '12.345.678/0001-11',
    telefone: '(35) 98888-7878',
    email: 'contato@teste.com',
  );

  try {
    print('1. Tentando cadastrar cliente no MySQL...');
    final clienteSalvo = await clienteService.cadastrarCliente(novoCliente);
    print('   ✓ Cliente Gravado no Banco Real! ID AutoIncrement: ${clienteSalvo.idCliente}');

    print('\n2. Buscando o cliente recém-criado pelo CNPJ...');
    final busca = await clienteService.buscarPorCpfCnpj('12.345.678/0001-99');
    print('   ✓ Encontrado no MySQL: ${busca?.nome} (ID: ${busca?.idCliente})');

  } catch (e) {
    print('Erro: $e');
  }
}