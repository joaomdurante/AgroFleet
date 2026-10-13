import '../models/maquinario.dart';
import 'base_repository_mysql.dart';

/// Repositório MySQL encarregado da persistência na tabela `maquinario`.
class MaquinarioRepositoryMysql extends BaseRepositoryMysql {
  
  /// Insere um novo registro de maquinário na base de dados.
  Future<Maquinario> salvar(Maquinario maquinario) async {
    final result = await executarQuery(
      'INSERT INTO maquinario (idFazenda, Descricao, Modelo, Marca, AnoFabricacao, HorimetroAtual, DataAquisicao, Status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
      [
        maquinario.idFazenda,
        maquinario.descricao,
        maquinario.modelo,
        maquinario.marca,
        maquinario.anoFabricacao,
        maquinario.horimetroAtual,
        maquinario.dataAquisicao?.toIso8601String().split('T').first,
        maquinario.status,
      ],
    );

    final idGerado = result.insertId!;

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
  }

  /// Recupera os dados de um maquinário a partir da sua chave primária.
  Future<Maquinario?> buscarPorId(int id) async {
    final results = await executarQuery(
      'SELECT idMaquinario, idFazenda, Descricao, Modelo, Marca, AnoFabricacao, HorimetroAtual, DataAquisicao, Status FROM maquinario WHERE idMaquinario = ?',
      [id],
    );

    if (results.isEmpty) return null;

    final linha = results.first;

    return Maquinario(
      idMaquinario: linha['idMaquinario'] as int,
      idFazenda: linha['idFazenda'] as int,
      descricao: linha['Descricao'] as String,
      modelo: linha['Modelo'] as String?,
      marca: linha['Marca'] as String?,
      anoFabricacao: linha['AnoFabricacao'] as int?,
      horimetroAtual: (linha['HorimetroAtual'] as num).toDouble(),
      dataAquisicao: linha['DataAquisicao'] != null ? DateTime.parse(linha['DataAquisicao'].toString()) : null,
      status: linha['Status'] as String,
    );
  }

  /// Atualiza o status e a leitura do horímetro na base de dados.
  Future<void> atualizar(Maquinario maquinario) async {
    await executarQuery(
      'UPDATE maquinario SET Status = ?, HorimetroAtual = ? WHERE idMaquinario = ?',
      [maquinario.status, maquinario.horimetroAtual, maquinario.idMaquinario],
    );
  }
}