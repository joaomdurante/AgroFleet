import '../models/destino_sustentavel.dart';
import 'base_repository_mysql.dart';

/// Repositório MySQL encarregado da tabela `destinosustentavel` (ODS 12).
class DestinoSustentavelRepositoryMysql extends BaseRepositoryMysql {

  /// Registra uma empresa receptora licenciada ambientalmente.
  Future<DestinoSustentavel> salvar(DestinoSustentavel destino) async {
    final cnpjLimpo = destino.cnpj.replaceAll(RegExp(r'\D'), '');

    final result = await executarQuery(
      'INSERT INTO destinosustentavel (EmpresaLicenciada, CNPJ, LicencaAmbiental, Telefone, Endereco) VALUES (?, ?, ?, ?, ?)',
      [
        destino.empresaLicenciada,
        cnpjLimpo,
        destino.licencaAmbiental,
        destino.telefone,
        destino.endereco,
      ],
    );

    final idGerado = result.insertId!;

    return DestinoSustentavel(
      idDestinoSustentavel: idGerado,
      empresaLicenciada: destino.empresaLicenciada,
      cnpj: cnpjLimpo,
      licencaAmbiental: destino.licencaAmbiental,
      telefone: destino.telefone,
      endereco: destino.endereco,
    );
  }

  /// Consulta um destino sustentável a partir do CNPJ sanitizado.
  Future<DestinoSustentavel?> buscarPorCnpj(String cnpj) async {
    final cnpjLimpo = cnpj.replaceAll(RegExp(r'\D'), '');

    final results = await executarQuery(
      'SELECT idDestinoSustentavel, EmpresaLicenciada, CNPJ, LicencaAmbiental, Telefone, Endereco FROM destinosustentavel WHERE CNPJ = ?',
      [cnpjLimpo],
    );

    if (results.isEmpty) return null;
    final linha = results.first;

    return DestinoSustentavel(
      idDestinoSustentavel: linha['idDestinoSustentavel'] as int,
      empresaLicenciada: linha['EmpresaLicenciada'] as String,
      cnpj: linha['CNPJ'] as String,
      licencaAmbiental: linha['LicencaAmbiental'] as String,
      telefone: linha['Telefone'] as String?,
      endereco: linha['Endereco'] as String?,
    );
  }

  /// Consulta um destino sustentável pelo seu ID.
  Future<DestinoSustentavel?> buscarPorId(int id) async {
    final results = await executarQuery(
      'SELECT idDestinoSustentavel, EmpresaLicenciada, CNPJ, LicencaAmbiental, Telefone, Endereco FROM destinosustentavel WHERE idDestinoSustentavel = ?',
      [id],
    );

    if (results.isEmpty) return null;
    final linha = results.first;

    return DestinoSustentavel(
      idDestinoSustentavel: linha['idDestinoSustentavel'] as int,
      empresaLicenciada: linha['EmpresaLicenciada'] as String,
      cnpj: linha['CNPJ'] as String,
      licencaAmbiental: linha['LicencaAmbiental'] as String,
      telefone: linha['Telefone'] as String?,
      endereco: linha['Endereco'] as String?,
    );
  }
}