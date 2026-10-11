import 'package:mysql1/mysql1.dart';

class Database {
  static Future<MySqlConnection> getConnection() async {
    final settings = ConnectionSettings(
      host: 'localhost',
      port: 3306,
      user: 'root',
      password: '', 
      db: 'projetointegrado',
    );

    return await MySqlConnection.connect(settings);
  }
}