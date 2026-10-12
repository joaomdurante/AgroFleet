import 'models/maquinario.dart';
import 'repositories/maquinario_repository_mysql.dart';
import 'repositories/ordem_servico_repository_mysql.dart';
import 'services/ordem_servico_service.dart';
import 'exceptions/regra_negocio_exception.dart';

/// Ponto de entrada da aplicação AgroFleet que executa o fluxo e testes e2e no MySQL.
void main() async {
  print('=== TESTANDO FLUXO COMPLETO DE OS NO MYSQL ===\n');

  // Instanciação dos repositórios de dados MySQL
  final maquinarioRepoSql = MaquinarioRepositoryMysql();
  final osRepoSql = OrdemServicoRepositoryMysql();
  
  // Injeção de dependências no serviço de Ordens de Serviço
  final osService = OrdemServicoService(osRepoSql, maquinarioRepoSql);

  try {
    // 1. Cadastra um equipamento de teste associado à Fazenda com ID 1
    print('1. Registrando equipamento no MySQL...');
    final tratorInput = Maquinario(
      idFazenda: 1, // Exige que a fazenda id=1 exista previamente no MySQL
      descricao: 'Trator Valtra A940',
      marca: 'Valtra',
      modelo: 'A940',
      anoFabricacao: 2023,
      horimetroAtual: 500.0,
      dataAquisicao: DateTime(2023, 3, 20),
      status: 'Ativo',
    );

    final tratorSalvo = await maquinarioRepoSql.salvar(tratorInput);
    print('   Maquinário salvo com ID: ${tratorSalvo.idMaquinario} | Status: ${tratorSalvo.status}');

    // 2. Abre Ordem de Serviço Preventiva e aplica trava de horímetro (550.0h)
    print('\n2. Abrindo OS para o equipamento ID #${tratorSalvo.idMaquinario}...');
    final osCriada = await osService.abrirOrdemServico(
      idMaquinario: tratorSalvo.idMaquinario!,
      tipo: 'Preventiva',
      horimetroInformado: 550.0,
      observacao: 'Troca de filtros e lubrificação geral.',
    );

    print('   OS #${osCriada.idOrdemServico} criada no banco!');

    // 3. Consulta o estado atualizado do equipamento no MySQL para confirmar o bloqueio ('Em manutencao')
    final tratorAtualizado = await maquinarioRepoSql.buscarPorId(tratorSalvo.idMaquinario!);
    print('   Novo status do equipamento no MySQL: ${tratorAtualizado?.status} | Horímetro: ${tratorAtualizado?.horimetroAtual}h');

    // 4. Conclui a manutenção e libera a máquina ('Ativo')
    print('\n3. Concluindo a OS #${osCriada.idOrdemServico}...');
    await osService.concluirOrdemServico(osCriada.idOrdemServico!);
    print('   OS Finalizada!');

    final tratorLiberado = await maquinarioRepoSql.buscarPorId(tratorSalvo.idMaquinario!);
    print('   Status do equipamento após conclusão: ${tratorLiberado?.status}');

  } on RegraNegocioException catch (e) {
    // Captura violações de regra de negócio
    print('Regra de Negócio: $e');
  } catch (e) {
    // Captura de falhas inesperadas no sistema, driver ou servidor MySQL
    print('Erro de Sistema: $e');
  }
}