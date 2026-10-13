import '../models/fazenda.dart';
import 'base_repository_mysql.dart';

/// Repositório MySQL encarregado da persistência na tabela `fazenda`.
class FazendaRepositoryMysql extends BaseRepositoryMysql {

  /// Insere uma nova fazenda vinculada a um cliente.
  Future<Fazenda> salvar(Fazenda fazenda) async {
    final result = await executarQuery(
      'INSERT INTO fazenda (idCliente, Nome, Endereco, Cidade, Estado) VALUES (?, ?, ?, ?, ?)',
      [
        fazenda.idCliente,
        fazenda.nome,
        fazenda.endereco,
        fazenda.cidade,
        fazenda.estado,
      ],
    );

    final idGerado = result.insertId!;

    return Fazenda(
      idFazenda: idGerado,
      idCliente: fazenda.idCliente,
      nome: fazenda.nome,
      endereco: fazenda.endereco,
      cidade: fazenda.cidade,
      estado: fazenda.estado,
    );
  }

  /// Recupera uma fazenda pelo seu ID.
  Future<Fazenda?> buscarPorId(int id) async {
    final results = await executarQuery(
      'SELECT idFazenda, idCliente, Nome, Endereco, Cidade, Estado FROM fazenda WHERE idFazenda = ?',
      [id],
    );

    if (results.isEmpty) return null;
    final linha = results.first;

    return Fazenda(
      idFazenda: linha['idFazenda'] as int,
      idCliente: linha['idCliente'] as int,
      nome: linha['Nome'] as String,
      endereco: linha['Endereco'] as String?,
      cidade: linha['Cidade'] as String?,
      estado: linha['Estado'] as String?,
    );
  }

  /// Lista todas as fazendas pertencentes a um determinado cliente.
  Future<List<Fazenda>> listarPorCliente(int idCliente) async {
    final results = await executarQuery(
      'SELECT idFazenda, idCliente, Nome, Endereco, Cidade, Estado FROM fazenda WHERE idCliente = ?',
      [idCliente],
    );

    return results.map((linha) => Fazenda(
      idFazenda: linha['idFazenda'] as int,
      idCliente: linha['idCliente'] as int,
      nome: linha['Nome'] as String,
      endereco: linha['Endereco'] as String?,
      cidade: linha['Cidade'] as String?,
      estado: linha['Estado'] as String?,
    )).toList();
  }
}