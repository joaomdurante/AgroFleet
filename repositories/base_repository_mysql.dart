import 'package:mysql1/mysql1.dart';
import '../database/mysql_connection.dart';

/// Classe mãe abstrata responsável por centralizar o gerenciamento de conexões com o MySQL.
/// Todas as classes filhas herdam os métodos de execução, eliminando a repetição do ciclo try/finally.
abstract class BaseRepositoryMysql {

  /// Executa comandos SQL (SELECT, INSERT, UPDATE, DELETE) de forma parametrizada.
  /// Abre a conexão, executa a instrução com segurança contra SQL Injection e garante o fechamento no 'finally'.
  Future<Results> executarQuery(String sql, [List<Object?>? parametros]) async {
    // Requisita a conexão ativa com o servidor MySQL
    final conn = await Database.getConnection();

    try {
      // Executa a instrução SQL parametrizada
      return await conn.query(sql, parametros);
    } finally {
      // Garante que a conexão seja sempre encerrada após a operação, evitando vazamento de recursos
      await conn.close();
    }
  }
}