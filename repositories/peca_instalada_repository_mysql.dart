import 'base_repository_mysql.dart';

/// Repositório MySQL encarregado de gerenciar o histórico de montagem em `peca_instalada`.
class PecaInstaladaRepositoryMysql extends BaseRepositoryMysql {

  /// Registra a instalação efetiva de uma peça no maquinário durante uma OS.
  /// Se a máquina já possuía a mesma peça instalada, marca a anterior como 'Removida'.
  Future<void> registrarInstalacao({
    required int idMaquinario,
    required int idPeca,
    required double horimetroInstalacao,
    required int idOrdemServicoInstalacao,
  }) async {
    // 1. Marca a peça que estava montada anteriormente como 'Removida'
    await executarQuery(
      '''
      UPDATE peca_instalada 
      SET Status = 'Removida', DataRemocao = ?, HorimetroRemocao = ?, idOrdemServicoRemocao = ? 
      WHERE idMaquinario = ? AND idPeca = ? AND Status = 'Instalada'
      ''',
      [
        DateTime.now().toIso8601String().split('T').first,
        horimetroInstalacao,
        idOrdemServicoInstalacao,
        idMaquinario,
        idPeca,
      ],
    );

    // 2. Insere a nova peça montada
    await executarQuery(
      '''
      INSERT INTO peca_instalada (idMaquinario, idPeca, DataInstalacao, HorimetroInstalacao, idOrdemServicoInstalacao, Status) 
      VALUES (?, ?, ?, ?, ?, 'Instalada')
      ''',
      [
        idMaquinario,
        idPeca,
        DateTime.now().toIso8601String().split('T').first,
        horimetroInstalacao,
        idOrdemServicoInstalacao,
      ],
    );
  }
}