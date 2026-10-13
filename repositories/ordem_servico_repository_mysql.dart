import '../models/ordem_servico.dart';
import 'base_repository_mysql.dart';

/// Repositório MySQL encarregado das operações de persistência na tabela `ordemservico`.
class OrdemServicoRepositoryMysql extends BaseRepositoryMysql {

  Future<OrdemServico> salvar(OrdemServico os) async {
    final result = await executarQuery(
      'INSERT INTO ordemservico (idMaquinario, Tipo, Status, DataAbertura, DataConclusao, HorimetroMomento, PendenciaAmbiental, Observacao) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [
        os.idMaquinario,
        os.tipo,
        os.status,
        os.dataAbertura.toUtc(),
        os.dataConclusao?.toUtc(),
        os.horimetroMomento,
        os.pendenciaAmbiental ? 1 : 0,
        os.observacao,
      ],
    );

    final idGerado = result.insertId!;

    return OrdemServico(
      idOrdemServico: idGerado,
      idMaquinario: os.idMaquinario,
      tipo: os.tipo,
      status: os.status,
      dataAbertura: os.dataAbertura,
      dataConclusao: os.dataConclusao,
      horimetroMomento: os.horimetroMomento,
      pendenciaAmbiental: os.pendenciaAmbiental,
      observacao: os.observacao,
    );
  }

  Future<OrdemServico?> buscarPorId(int id) async {
    final results = await executarQuery(
      'SELECT idOrdemServico, idMaquinario, Tipo, Status, DataAbertura, DataConclusao, HorimetroMomento, PendenciaAmbiental, Observacao FROM ordemservico WHERE idOrdemServico = ?',
      [id],
    );

    if (results.isEmpty) return null;
    final linha = results.first;

    return OrdemServico(
      idOrdemServico: linha['idOrdemServico'] as int,
      idMaquinario: linha['idMaquinario'] as int,
      tipo: linha['Tipo'] as String,
      status: linha['Status'] as String,
      dataAbertura: (linha['DataAbertura'] as DateTime).toLocal(),
      dataConclusao: linha['DataConclusao'] != null ? (linha['DataConclusao'] as DateTime).toLocal() : null,
      horimetroMomento: (linha['HorimetroMomento'] as num).toDouble(),
      pendenciaAmbiental: (linha['PendenciaAmbiental'] as int) == 1,
      observacao: linha['Observacao'] as String?,
    );
  }

  Future<void> atualizar(OrdemServico os) async {
    await executarQuery(
      'UPDATE ordemservico SET Status = ?, DataConclusao = ?, HorimetroMomento = ?, PendenciaAmbiental = ?, Observacao = ? WHERE idOrdemServico = ?',
      [
        os.status,
        os.dataConclusao?.toUtc(),
        os.horimetroMomento,
        os.pendenciaAmbiental ? 1 : 0,
        os.observacao,
        os.idOrdemServico,
      ],
    );
  }

  /// Altera o estado da pendência ambiental de uma Ordem de Serviço.
  Future<void> atualizarPendenciaAmbiental(int idOrdemServico, bool temPendencia) async {
    await executarQuery(
      'UPDATE ordemservico SET PendenciaAmbiental = ? WHERE idOrdemServico = ?',
      [temPendencia ? 1 : 0, idOrdemServico],
    );
  }

  /// Calcula o custo financeiro total da OS com base em mão de obra e peças efetivamente instaladas.
  Future<Map<String, double>> calcularCustoTotalOS(int idOrdemServico) async {
    final sqlMaoObra = '''
      SELECT COALESCE(SUM((TIME_TO_SEC(TIMEDIFF(a.HoraFim, a.HoraInicio)) / 3600.0) * t.ValorHora), 0) AS CustoMaoObra
      FROM alocacaotecnico a
      JOIN tecnico t ON a.idTecnico = t.idTecnico
      WHERE a.idOrdemServico = ?
    ''';
    final resMaoObra = await executarQuery(sqlMaoObra, [idOrdemServico]);
    final custoMaoObra = (resMaoObra.first['CustoMaoObra'] as num).toDouble();

    final sqlPecas = '''
      SELECT COALESCE(SUM(ir.Quantidade * ir.PrecoUnitario), 0) AS CustoPecas
      FROM requisicaopeca rp
      JOIN itemrequisicao ir ON rp.idRequisicaoPeca = ir.idRequisicaoPeca
      WHERE rp.idOrdemServico = ?
    ''';
    final resPecas = await executarQuery(sqlPecas, [idOrdemServico]);
    final custoPecas = (resPecas.first['CustoPecas'] as num).toDouble();

    return {
      'maoObra': custoMaoObra,
      'pecas': custoPecas,
      'total': custoMaoObra + custoPecas,
    };
  }
}