import '../models/cliente.dart';
import '../repositories/cliente_repository_mysql.dart';
import '../exceptions/regra_negocio_exception.dart';

/// Classe de serviço que centraliza as regras de negócio associadas aos Clientes e Cadastro Rápido.
class ClienteService {
  // Dependência do repositório de clientes MySQL
  final ClienteRepositoryMysql _clienteRepository;

  /// Injeção do repositório via construtor
  ClienteService(this._clienteRepository);

  /// Efetua a pesquisa de um cliente por CPF/CNPJ validando o preenchimento da entrada
  Future<Cliente?> buscarPorCpfCnpj(String cpfCnpj) async {
    // Valida se o documento fornecido não está em branco
    if (cpfCnpj.trim().isEmpty) {
      throw RegraNegocioException('CPF/CNPJ não pode ser vazio para busca.');
    }
    // Delega a pesquisa ao repositório MySQL
    return await _clienteRepository.buscarPorCpfCnpj(cpfCnpj);
  }

  /// Regra de Negócio: Regista um novo cliente garantindo a não duplicidade do documento
  Future<Cliente> cadastrarCliente(Cliente cliente) async {
    // 1. Sanitização do documento para conter apenas números
    final docLimpo = cliente.documento.replaceAll(RegExp(r'\D'), '');
    if (docLimpo.isEmpty) {
      throw RegraNegocioException('O documento (CPF/CNPJ) é obrigatório.');
    }

    // 2. Impede a duplicação de cadastros para o mesmo CPF/CNPJ
    final clienteExistente = await _clienteRepository.buscarPorCpfCnpj(docLimpo);
    if (clienteExistente != null) {
      throw RegraNegocioException('Já existe um cliente cadastrado com o CPF/CNPJ informado.');
    }

    // 3. Validação do tamanho mínimo do nome do cliente
    if (cliente.nome.trim().length < 3) {
      throw RegraNegocioException('O nome do cliente deve ter no mínimo 3 caracteres.');
    }

    // Persiste o novo cliente no banco de dados através do repositório
    return await _clienteRepository.salvar(cliente);
  }
}