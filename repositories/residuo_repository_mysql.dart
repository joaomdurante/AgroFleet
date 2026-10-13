import '../models/residuo.dart';
import 'base_repository_mysql.dart';

/// Repositório MySQL encarregado do registro detalhado na tabela `residuo`.
class ResiduoRepositoryMysql extends BaseRepositoryMysql {

  /// Persiste um resíduo gerado na OS.
  Future<Residuo> salvar(Residuo residuo) async {
    final result = await executarQuery(
      'INSERT INTO residuo (idOrdemServico, idDestinoSustentavel, Tipo, Quantidade, DataGeracao, Observacao, Status) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [
        residuo.idOrdemServico,
        residuo.idDestinoSustentavel,
        residuo.tipo,
        residuo.quantidade,
        residuo.dataGeracao.toUtc(),
        residuo.observacao,
        residuo.status,
      ],
    );

    final idGerado = result.insertId!;

    return Residuo(
      idResiduo: idGerado,
      idOrdemServico: residuo.idOrdemServico,
      idDestinoSustentavel: residuo.idDestinoSustentavel,
      tipo: residuo.tipo,
      quantidade: residuo.quantidade,
      dataGeracao: residuo.dataGeracao,
      observacao: residuo.observacao,
      status: residuo.status,
    );
  }

  /// Recupera todos os resíduos com status 'Pendente' associados a uma OS.
  Future<List<Residuo>> listarPendentesPorOrdemServico(int idOrdemServico) async {
    final results = await executarQuery(
      "SELECT idResiduo, idOrdemServico, idDestinoSustentavel, Tipo, Quantidade, DataGeracao, Observacao, Status FROM residuo WHERE idOrdemServico = ? AND Status = 'Pendente'",
      [idOrdemServico],
    );

    return results.map((linha) => Residuo(
      idResiduo: linha['idResiduo'] as int,
      idOrdemServico: linha['idOrdemServico'] as int,
      idDestinoSustentavel: linha['idDestinoSustentavel'] as int?,
      tipo: linha['Tipo'] as String,
      quantidade: (linha['Quantidade'] as num).toDouble(),
      dataGeracao: (linha['DataGeracao'] as DateTime).toLocal(),
      observacao: linha['Observacao'] as String?,
      status: linha['Status'] as String,
    )).toList();
  }

  /// Efetua o descarte (Total ou Parcial) calculando o saldo faltante.
  Future<void> registrarDescarte({
    required Residuo residuoPendente,
    required double qtdDescartada,
    required int idDestinoSustentavel,
  }) async {
    if (qtdDescartada >= residuoPendente.quantidade) {
      // Descarte Total do item
      await executarQuery(
        "UPDATE residuo SET idDestinoSustentavel = ?, Status = 'Descartado', Quantidade = ? WHERE idResiduo = ?",
        [idDestinoSustentavel, qtdDescartada, residuoPendente.idResiduo],
      );
    } else {
      // Descarte Parcial:
      // 1. Atualiza o saldo faltante a ser descartado no registro original
      final saldoFaltante = residuoPendente.quantidade - qtdDescartada;
      await executarQuery(
        "UPDATE residuo SET Quantidade = ? WHERE idResiduo = ?",
        [saldoFaltante, residuoPendente.idResiduo],
      );

      // 2. Insere um novo registro de histórico para a fração efetivamente descartada
      await executarQuery(
        "INSERT INTO residuo (idOrdemServico, idDestinoSustentavel, Tipo, Quantidade, DataGeracao, Observacao, Status) VALUES (?, ?, ?, ?, ?, ?, 'Descartado')",
        [
          residuoPendente.idOrdemServico,
          idDestinoSustentavel,
          residuoPendente.tipo,
          qtdDescartada,
          DateTime.now().toUtc(),
          "Coleta Parcial de ${qtdDescartada} (Saldo Faltante:${saldoFaltante})",
        ],
      );
    }
  }

  /// Verifica se ainda existe algum resíduo pendente para a OS.
  Future<bool> possuiResiduoPendente(int idOrdemServico) async {
    final results = await executarQuery(
      "SELECT COUNT(*) as Qtd FROM residuo WHERE idOrdemServico = ? AND Status = 'Pendente'",
      [idOrdemServico],
    );
    final count = (results.first['Qtd'] as num).toInt();
    return count > 0;
  }
}