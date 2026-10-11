import '../database/mysql_connection.dart';
import '../models/cliente.dart';

class ClienteRepositoryMysql {
  
  /// Insere um novo cliente na tabela 'cliente' do MySQL
  Future<Cliente> salvar(Cliente cliente) async {
    final conn = await Database.getConnection();

    try {
      final docLimpo = cliente.documento.replaceAll(RegExp(r'\D'), '');

      final result = await conn.query(
        'INSERT INTO cliente (Nome, Documento, Telefone, Email) VALUES (?, ?, ?, ?)',
        [cliente.nome, docLimpo, cliente.telefone, cliente.email],
      );

      // Obtém o ID gerado pelo AUTO_INCREMENT do MySQL
      final idGerado = result.insertId!;

      return Cliente(
        idCliente: idGerado,
        nome: cliente.nome,
        documento: docLimpo,
        telefone: cliente.telefone,
        email: cliente.email,
      );
    } finally {
      // Fecha a conexão após a operação
      await conn.close();
    }
  }

  /// Busca cliente por CPF ou CNPJ no MySQL
  Future<Cliente?> buscarPorCpfCnpj(String cpfCnpj) async {
    final conn = await Database.getConnection();
    final docLimpo = cpfCnpj.replaceAll(RegExp(r'\D'), '');

    try {
      final results = await conn.query(
        'SELECT idCliente, Nome, Documento, Telefone, Email FROM cliente WHERE Documento = ?',
        [docLimpo],
      );

      if (results.isEmpty) {
        return null; // Cliente não cadastrado no MySQL
      }

      final linha = results.first;
      return Cliente(
        idCliente: linha['idCliente'] as int,
        nome: linha['Nome'] as String,
        documento: linha['Documento'] as String,
        telefone: linha['Telefone'] as String?,
        email: linha['Email'] as String?,
      );
    } finally {
      await conn.close();
    }
  }
}