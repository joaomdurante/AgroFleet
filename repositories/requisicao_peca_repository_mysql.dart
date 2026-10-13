import '../models/requisicao_peca.dart';
import '../models/item_requisicao.dart';
import 'base_repository_mysql.dart';

/// Repositório MySQL encarregado das requisições de peças e seus itens.
class RequisicaoPecaRepositoryMysql extends BaseRepositoryMysql {

  /// Insere uma requisição de peças vinculada a uma Ordem de Serviço.
  Future<RequisicaoPeca> salvar(RequisicaoPeca requisicao) async {
    final result = await executarQuery(
      'INSERT INTO requisicaopeca (idOrdemServico, DataRequisicao, Finalidade) VALUES (?, ?, ?)',
      [
        requisicao.idOrdemServico,
        requisicao.dataRequisicao.toUtc(),
        requisicao.finalidade,
      ],
    );

    final idGerado = result.insertId!;

    return RequisicaoPeca(
      idRequisicaoPeca: idGerado,
      idOrdemServico: requisicao.idOrdemServico,
      dataRequisicao: requisicao.dataRequisicao,
      finalidade: requisicao.finalidade,
    );
  }

  /// Adiciona um item individual de peça à requisição criada.
  Future<void> adicionarItem(ItemRequisicao item) async {
    await executarQuery(
      'INSERT INTO itemrequisicao (idRequisicaoPeca, idPeca, Quantidade, PrecoUnitario) VALUES (?, ?, ?, ?)',
      [
        item.idRequisicaoPeca,
        item.idPeca,
        item.quantidade,
        item.precoUnitario,
      ],
    );
  }
}