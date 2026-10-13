import '../models/cliente.dart';
import 'base_repository_mysql.dart';

/// Repositório MySQL encarregado das operações de persistência na tabela `cliente`.
/// Herda de [BaseRepositoryMysql] para reusar o gerenciamento automático de conexões.
class ClienteRepositoryMysql extends BaseRepositoryMysql {
  
  /// Insere um novo cliente na tabela `cliente` do MySQL.
  Future<Cliente> salvar(Cliente cliente) async {
    // Remove caracteres não numéricos do CPF/CNPJ antes de persistir
    final docLimpo = cliente.documento.replaceAll(RegExp(r'\D'), '');

    // Utiliza o método herdado 'executarQuery' para executar o INSERT de forma parametrizada
    final result = await executarQuery(
      'INSERT INTO cliente (Nome, Documento, Telefone, Email) VALUES (?, ?, ?, ?)',
      [cliente.nome, docLimpo, cliente.telefone, cliente.email],
    );

    // Resgata o ID gerado pelo AUTO_INCREMENT do MySQL
    final idGerado = result.insertId!;

    // Retorna o objeto Cliente atualizado com a chave primária atribuída
    return Cliente(
      idCliente: idGerado,
      nome: cliente.nome,
      documento: docLimpo,
      telefone: cliente.telefone,
      email: cliente.email,
    );
  }

  /// Realiza a pesquisa de um cliente a partir do seu número de CPF ou CNPJ.
  Future<Cliente?> buscarPorCpfCnpj(String cpfCnpj) async {
    final docLimpo = cpfCnpj.replaceAll(RegExp(r'\D'), '');

    // Reutiliza a consulta parametrizada da classe mãe
    final results = await executarQuery(
      'SELECT idCliente, Nome, Documento, Telefone, Email FROM cliente WHERE Documento = ?',
      [docLimpo],
    );

    // Retorna nulo caso o registro não exista na tabela
    if (results.isEmpty) return null;

    final linha = results.first;
    
    // Converte as colunas do MySQL para o modelo de domínio Cliente
    return Cliente(
      idCliente: linha['idCliente'] as int,
      nome: linha['Nome'] as String,
      documento: linha['Documento'] as String,
      telefone: linha['Telefone'] as String?,
      email: linha['Email'] as String?,
    );
  }
}