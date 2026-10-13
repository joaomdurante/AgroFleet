import '../models/tecnico.dart';
import 'base_repository_mysql.dart';

/// Repositório MySQL encarregado da persistência na tabela `tecnico`.
class TecnicoRepositoryMysql extends BaseRepositoryMysql {

  /// Insere um novo técnico no banco de dados.
  Future<Tecnico> salvar(Tecnico tecnico) async {
    final result = await executarQuery(
      'INSERT INTO tecnico (Nome, Telefone, Email, Ativo, ValorHora) VALUES (?, ?, ?, ?, ?)',
      [
        tecnico.nome,
        tecnico.telefone,
        tecnico.email,
        tecnico.ativo ? 1 : 0,
        tecnico.valorHora,
      ],
    );

    final idGerado = result.insertId!;

    return Tecnico(
      idTecnico: idGerado,
      nome: tecnico.nome,
      telefone: tecnico.telefone,
      email: tecnico.email,
      ativo: tecnico.ativo,
      valorHora: tecnico.valorHora,
    );
  }

  /// Recupera um técnico a partir do seu identificador primário.
  Future<Tecnico?> buscarPorId(int id) async {
    final results = await executarQuery(
      'SELECT idTecnico, Nome, Telefone, Email, Ativo, ValorHora FROM tecnico WHERE idTecnico = ?',
      [id],
    );

    if (results.isEmpty) return null;
    final linha = results.first;

    return Tecnico(
      idTecnico: linha['idTecnico'] as int,
      nome: linha['Nome'] as String,
      telefone: linha['Telefone'] as String?,
      email: linha['Email'] as String?,
      ativo: (linha['Ativo'] as int) == 1,
      valorHora: (linha['ValorHora'] as num).toDouble(),
    );
  }
}