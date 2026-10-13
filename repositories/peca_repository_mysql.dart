import '../models/peca.dart';
import 'base_repository_mysql.dart';

/// Repositório MySQL encarregado das operações na tabela `peca`.
class PecaRepositoryMysql extends BaseRepositoryMysql {

  /// Cadastra uma nova peça/insumo no catálogo.
  Future<Peca> salvar(Peca peca) async {
    final result = await executarQuery(
      'INSERT INTO peca (Descricao, Tipo, VidaUtilHorimetro, UnidadeMedida) VALUES (?, ?, ?, ?)',
      [
        peca.descricao,
        peca.tipo,
        peca.vidaUtilHorimetro,
        peca.unidadeMedida,
      ],
    );

    final idGerado = result.insertId!;

    return Peca(
      idPeca: idGerado,
      descricao: peca.descricao,
      tipo: peca.tipo,
      vidaUtilHorimetro: peca.vidaUtilHorimetro,
      unidadeMedida: peca.unidadeMedida,
    );
  }

  /// Retorna a lista de todas as peças cadastradas.
  Future<List<Peca>> listarTodas() async {
    final results = await executarQuery(
      'SELECT idPeca, Descricao, Tipo, VidaUtilHorimetro, UnidadeMedida FROM peca',
    );

    return results.map((linha) => Peca(
      idPeca: linha['idPeca'] as int,
      descricao: linha['Descricao'] as String,
      tipo: linha['Tipo'] as String,
      vidaUtilHorimetro: linha['VidaUtilHorimetro'] != null 
          ? (linha['VidaUtilHorimetro'] as num).toDouble() 
          : null,
      unidadeMedida: linha['UnidadeMedida'] as String,
    )).toList();
  }
}