import '../database/mysql_connection.dart';
import '../models/cliente.dart';

/// Repositório MySQL encarregado das operações de persitência na tabela `cliente`.
class ClienteRepositoryMysql {
  
  /// Insere um novo cliente na tabela `cliente` do MySQL.
  Future<Cliente> salvar(Cliente cliente) async {
    // Requisita uma conexão ativa com o MySQL
    final conn = await Database.getConnection();

    try {
      // Remove caracteres não numéricos do CPF/CNPJ antes de persistir
      final docLimpo = cliente.documento.replaceAll(RegExp(r'\D'), '');

      // Executa a instrução SQL de inserção parametrizada para prevenir SQL Injection
      final result = await conn.query(
        'INSERT INTO cliente (Nome, Documento, Telefone, Email) VALUES (?, ?, ?, ?)',
        [cliente.nome, docLimpo, cliente.telefone, cliente.email],
      );

      // Resgata o ID atribuído pela coluna AUTO_INCREMENT
      final idGerado = result.insertId!;

      // Retorna o objeto Cliente completo com a chave primária atribuída
      return Cliente(
        idCliente: idGerado,
        nome: cliente.nome,
        documento: docLimpo,
        telefone: cliente.telefone,
        email: cliente.email,
      );
    } finally {
      // Encerra a conexão com a base de dados de forma segura no bloco 'finally'
      await conn.close();
    }
  }

  /// Realiza a pesquisa de um cliente a partir do seu número de CPF ou CNPJ.
  Future<Cliente?> buscarPorCpfCnpj(String cpfCnpj) async {
    // Abre a conexão com a base de dados
    final conn = await Database.getConnection();
    // Limpa pontuações do documento para manter o padrão de busca
    final docLimpo = cpfCnpj.replaceAll(RegExp(r'\D'), '');

    try {
      // Executa a consulta SELECT parametrizada pelo documento
      final results = await conn.query(
        'SELECT idCliente, Nome, Documento, Telefone, Email FROM cliente WHERE Documento = ?',
        [docLimpo],
      );

      // Retorna nulo caso o registo não exista na tabela
      if (results.isEmpty) {
        return null;
      }

      // Obtém o primeiro registo retornado
      final linha = results.first;
      
      // Converte as colunas SQL para uma instância de modelo Cliente
      return Cliente(
        idCliente: linha['idCliente'] as int,
        nome: linha['Nome'] as String,
        documento: linha['Documento'] as String,
        telefone: linha['Telefone'] as String?,
        email: linha['Email'] as String?,
      );
    } finally {
      // Garante o fecho da conexão
      await conn.close();
    }
  }
}