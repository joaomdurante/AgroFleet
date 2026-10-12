import '../database/mysql_connection.dart';
import '../models/maquinario.dart';

/// Repositório MySQL encarregado da persistência na tabela `maquinario`.
class MaquinarioRepositoryMysql {
  
  /// Insere um novo registo de maquinário na base de dados MySQL.
  Future<Maquinario> salvar(Maquinario maquinario) async {
    // Abre a conexão com o MySQL
    final conn = await Database.getConnection();

    try {
      // Executa o comando INSERT preenchendo as colunas da tabela `maquinario`
      final result = await conn.query(
        'INSERT INTO maquinario (idFazenda, Descricao, Modelo, Marca, AnoFabricacao, HorimetroAtual, DataAquisicao, Status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        [
          maquinario.idFazenda,                                        // FK da fazenda vinculada
          maquinario.descricao,                                        // Descrição/Nome da máquina
          maquinario.modelo,                                           // Modelo comercial
          maquinario.marca,                                            // Marca fabricante
          maquinario.anoFabricacao,                                    // Ano de fabricação
          maquinario.horimetroAtual,                                   // Valor numérico das horas do motor
          maquinario.dataAquisicao?.toIso8601String().split('T').first, // Formata DateTime para a String 'YYYY-MM-DD'
          maquinario.status,                                           // Estado do equipamento ('Ativo', etc.)
        ],
      );

      // Resgata a chave primária auto-incrementada atribuída pelo banco
      final idGerado = result.insertId!;

      // Devolve o modelo Maquinario com o ID gerado
      return Maquinario(
        idMaquinario: idGerado,
        idFazenda: maquinario.idFazenda,
        descricao: maquinario.descricao,
        modelo: maquinario.modelo,
        marca: maquinario.marca,
        anoFabricacao: maquinario.anoFabricacao,
        horimetroAtual: maquinario.horimetroAtual,
        dataAquisicao: maquinario.dataAquisicao,
        status: maquinario.status,
      );
    } finally {
      // Fecha a conexão com o MySQL
      await conn.close();
    }
  }

  /// Recupera os dados de um maquinário registado a partir da sua chave primária.
  Future<Maquinario?> buscarPorId(int id) async {
    // Estabelece a conexão com a base de dados
    final conn = await Database.getConnection();

    try {
      // Executa a instrução SELECT filtrando por `idMaquinario`
      final results = await conn.query(
        'SELECT idMaquinario, idFazenda, Descricao, Modelo, Marca, AnoFabricacao, HorimetroAtual, DataAquisicao, Status FROM maquinario WHERE idMaquinario = ?',
        [id],
      );

      // Retorna nulo se o ID não for encontrado
      if (results.isEmpty) return null;

      // Extrai a linha encontrada
      final linha = results.first;

      // Converte as colunas SQL para o modelo Maquinario em Dart
      return Maquinario(
        idMaquinario: linha['idMaquinario'] as int,                     // Converte a chave primária
        idFazenda: linha['idFazenda'] as int,                           // Converte a FK da fazenda
        descricao: linha['Descricao'] as String,                        // Converte a descrição
        modelo: linha['Modelo'] as String?,                             // Campo opcional
        marca: linha['Marca'] as String?,                               // Campo opcional
        anoFabricacao: linha['AnoFabricacao'] as int?,                 // Campo opcional
        horimetroAtual: (linha['HorimetroAtual'] as num).toDouble(),    // Converte tipos numéricos do banco de forma segura para double
        dataAquisicao: linha['DataAquisicao'] != null ? DateTime.parse(linha['DataAquisicao'].toString()) : null, // Converte a data
        status: linha['Status'] as String,                               // Status atual
      );
    } finally {
      // Encerra a sessão da conexão
      await conn.close();
    }
  }

  /// Atualiza o status e a contagem de horas do horímetro na base de dados.
  Future<void> atualizar(Maquinario maquinario) async {
    // Estabelece a conexão
    final conn = await Database.getConnection();

    try {
      // Executa o comando UPDATE alterando Status e HorimetroAtual
      await conn.query(
        'UPDATE maquinario SET Status = ?, HorimetroAtual = ? WHERE idMaquinario = ?',
        [maquinario.status, maquinario.horimetroAtual, maquinario.idMaquinario],
      );
    } finally {
      // Encerra a conexão
      await conn.close();
    }
  }
}