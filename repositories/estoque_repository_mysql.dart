import 'base_repository_mysql.dart';

/// Repositório MySQL encarregado do controle de saldos e movimentação na tabela `estoque`.
class EstoqueRepositoryMysql extends BaseRepositoryMysql {

  /// Registra ou atualiza o saldo de estoque de uma peça.
  Future<void> salvarOuAtualizar(int idPeca, double quantidadeAtual, double nivelMinimo, String localizacao) async {
    final checagem = await executarQuery(
      'SELECT idEstoque FROM estoque WHERE idPeca = ?',
      [idPeca],
    );

    if (checagem.isEmpty) {
      await executarQuery(
        'INSERT INTO estoque (idPeca, QuantidadeAtual, NivelMinimo, Localizacao) VALUES (?, ?, ?, ?)',
        [idPeca, quantidadeAtual, nivelMinimo, localizacao],
      );
    } else {
      await executarQuery(
        'UPDATE estoque SET QuantidadeAtual = ?, NivelMinimo = ?, Localizacao = ? WHERE idPeca = ?',
        [quantidadeAtual, nivelMinimo, localizacao, idPeca],
      );
    }
  }

  /// Realiza a baixa (saída) de saldo no estoque de uma peça.
  Future<void> darBaixaEstoque(int idPeca, double quantidade) async {
    await executarQuery(
      'UPDATE estoque SET QuantidadeAtual = QuantidadeAtual - ? WHERE idPeca = ? AND QuantidadeAtual >= ?',
      [quantidade, idPeca, quantidade],
    );
  }

  /// Realiza o estorno (devolução) de peças não utilizadas de volta ao estoque.
  Future<void> estornarEstoque(int idPeca, double quantidade) async {
    await executarQuery(
      'UPDATE estoque SET QuantidadeAtual = QuantidadeAtual + ? WHERE idPeca = ?',
      [quantidade, idPeca],
    );
  }

  /// Consulta o saldo atual de uma peça no estoque.
  Future<double> buscarSaldoAtual(int idPeca) async {
    final res = await executarQuery(
      'SELECT QuantidadeAtual FROM estoque WHERE idPeca = ?',
      [idPeca],
    );
    if (res.isEmpty) return 0.0;
    return (res.first['QuantidadeAtual'] as num).toDouble();
  }
}