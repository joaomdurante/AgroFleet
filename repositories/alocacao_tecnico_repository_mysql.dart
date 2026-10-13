import '../models/alocacao_tecnico.dart';
import 'base_repository_mysql.dart';

/// Repositório MySQL encarregado dos apontamentos de horas na tabela `alocacaotecnico`.
class AlocacaoTecnicoRepositoryMysql extends BaseRepositoryMysql {

  /// Aponta horas técnicas trabalhadas em uma Ordem de Serviço.
  Future<AlocacaoTecnico> salvar(AlocacaoTecnico alocacao) async {
    final result = await executarQuery(
      'INSERT INTO alocacaotecnico (idTecnico, idOrdemServico, DataAlocacao, HoraInicio, HoraFim, Funcao) VALUES (?, ?, ?, ?, ?, ?)',
      [
        alocacao.idTecnico,
        alocacao.idOrdemServico,
        alocacao.dataAlocacao.toIso8601String().split('T').first,
        alocacao.horaInicio,
        alocacao.horaFim,
        alocacao.funcao,
      ],
    );

    final idGerado = result.insertId!;

    return AlocacaoTecnico(
      idAlocacaoTecnico: idGerado,
      idOrdemServico: alocacao.idOrdemServico,
      idTecnico: alocacao.idTecnico,
      dataAlocacao: alocacao.dataAlocacao,
      horaInicio: alocacao.horaInicio,
      horaFim: alocacao.horaFim,
      funcao: alocacao.funcao,
    );
  }
}