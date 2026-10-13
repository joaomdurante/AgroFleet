import 'base_repository_mysql.dart';

/// Repositório encarregado de gerenciar especialidades técnicas e vínculos N:M.
class EspecialidadeRepositoryMysql extends BaseRepositoryMysql {

  /// Associa um técnico a uma especialidade na tabela `tecnicoespecialidade`.
  Future<void> vincularEspecialidade(int idTecnico, int idEspecialidade) async {
    await executarQuery(
      'INSERT INTO tecnicoespecialidade (idTecnico, idEspecialidade) VALUES (?, ?)',
      [idTecnico, idEspecialidade],
    );
  }

  /// Cadastra uma nova especialidade caso não exista.
  Future<int> cadastrarOuBuscarEspecialidade(String nome, String? descricao) async {
    final busca = await executarQuery(
      'SELECT idEspecialidade FROM especialidade WHERE Nome = ?',
      [nome],
    );

    if (busca.isNotEmpty) {
      return busca.first['idEspecialidade'] as int;
    }

    final res = await executarQuery(
      'INSERT INTO especialidade (Nome, Descricao) VALUES (?, ?)',
      [nome, descricao],
    );
    return res.insertId!;
  }
}