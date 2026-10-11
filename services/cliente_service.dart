import '../models/cliente.dart';
import '../repositories/cliente_repository_mysql.dart';
import '../exceptions/regra_negocio_exception.dart';

class ClienteService {
  final ClienteRepositoryMysql _clienteRepository;

  ClienteService(this._clienteRepository);

  /// Busca cliente por CPF/CNPJ na base de dados MySQL
  Future<Cliente?> buscarPorCpfCnpj(String cpfCnpj) async {
    if (cpfCnpj.trim().isEmpty) {
      throw RegraNegocioException('CPF/CNPJ não pode ser vazio para busca.');
    }
    return await _clienteRepository.buscarPorCpfCnpj(cpfCnpj);
  }

  /// Realiza o cadastro do cliente
  Future<Cliente> cadastrarCliente(Cliente cliente) async {
    // 1. Validação de documento
    final docLimpo = cliente.documento.replaceAll(RegExp(r'\D'), '');
    if (docLimpo.isEmpty) {
      throw RegraNegocioException('O documento (CPF/CNPJ) é obrigatório.');
    }

    // 2. Impede duplicidade de CPF/CNPJ na base de dados
    final clienteExistente = await _clienteRepository.buscarPorCpfCnpj(docLimpo);
    if (clienteExistente != null) {
      throw RegraNegocioException('Já existe um cliente cadastrado com o CPF/CNPJ informado.');
    }

    // 3. Validação do nome
    if (cliente.nome.trim().length < 3) {
      throw RegraNegocioException('O nome do cliente deve ter no mínimo 3 caracteres.');
    }

    return await _clienteRepository.salvar(cliente);
  }
}