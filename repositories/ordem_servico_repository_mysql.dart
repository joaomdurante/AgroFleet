import '../database/mysql_connection.dart';
import '../models/ordem_servico.dart';

/// Repositório MySQL encarregado das operações de persistência na tabela `ordemservico`.
class OrdemServicoRepositoryMysql {

  /// Insere um novo registo de Ordem de Serviço na tabela `ordemservico`.
  Future<OrdemServico> salvar(OrdemServico os) async {
    // Abre a conexão assíncrona com o servidor MySQL
    final conn = await Database.getConnection();

    try {
      // Executa o comando INSERT parametrizado
      final result = await conn.query(
        'INSERT INTO ordemservico (idMaquinario, Tipo, Status, DataAbertura, DataConclusao, HorimetroMomento, PendenciaAmbiental, Observacao) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        [
          os.idMaquinario,               // FK do maquinário
          os.tipo,                       // Tipo da manutenção
          os.status,                     // Estado inicial da OS ('Aberta')
          os.dataAbertura.toUtc(),       // O driver mysql1 exige o envio explicito em formato UTC
          os.dataConclusao?.toUtc(),     // Data de conclusão em UTC (se definida)
          os.horimetroMomento,           // Leitura do horímetro no momento
          os.pendenciaAmbiental ? 1 : 0, // Mapeia o booleano do Dart para 1/0 do MySQL
          os.observacao,                 // Observações opcionais
        ],
      );

      // Resgata o ID gerado pelo AUTO_INCREMENT do MySQL
      final idGerado = result.insertId!;

      // Devolve o objeto instanciado com o ID
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
    } finally {
      // Fecha a conexão no bloco finally para garantir a libertação de recursos
      await conn.close();
    }
  }

  /// Recupera uma Ordem de Serviço pelo seu identificador primário.
  Future<OrdemServico?> buscarPorId(int id) async {
    // Requisita conexão com o banco
    final conn = await Database.getConnection();

    try {
      // Executa a consulta SELECT parametrizada
      final results = await conn.query(
        'SELECT idOrdemServico, idMaquinario, Tipo, Status, DataAbertura, DataConclusao, HorimetroMomento, PendenciaAmbiental, Observacao FROM ordemservico WHERE idOrdemServico = ?',
        [id],
      );

      // Se não houver registo correspondente, retorna nulo
      if (results.isEmpty) return null;

      // Obtém o registo localizado
      final linha = results.first;

      // Instancia a OrdemServico convertendo os tipos de dados do MySQL
      return OrdemServico(
        idOrdemServico: linha['idOrdemServico'] as int,
        idMaquinario: linha['idMaquinario'] as int,
        tipo: linha['Tipo'] as String,
        status: linha['Status'] as String,
        dataAbertura: (linha['DataAbertura'] as DateTime).toLocal(), // Converte do fuso UTC do driver para o fuso local do sistema
        dataConclusao: linha['DataConclusao'] != null ? (linha['DataConclusao'] as DateTime).toLocal() : null, // Converte a data de conclusão
        horimetroMomento: (linha['HorimetroMomento'] as num).toDouble(), // Cast do horímetro
        pendenciaAmbiental: (linha['PendenciaAmbiental'] as int) == 1,   // Mapeia inteiro para booleano
        observacao: linha['Observacao'] as String?,
      );
    } finally {
      // Encerra a conexão
      await conn.close();
    }
  }

  /// Atualiza o status, data de conclusão e observações de uma OS na base de dados.
  Future<void> atualizar(OrdemServico os) async {
    // Conecta à base de dados
    final conn = await Database.getConnection();

    try {
      // Executa a query de atualização
      await conn.query(
        'UPDATE ordemservico SET Status = ?, DataConclusao = ?, HorimetroMomento = ?, Observacao = ? WHERE idOrdemServico = ?',
        [
          os.status,
          os.dataConclusao?.toUtc(), // Converte a data de conclusão para UTC
          os.horimetroMomento,
          os.observacao,
          os.idOrdemServico,
        ],
      );
    } finally {
      // Fecha a conexão
      await conn.close();
    }
  }
}