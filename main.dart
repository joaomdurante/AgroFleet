import './cliente.dart';
import './fazenda.dart';
import './maquinario.dart';
import 'ordem_servico.dart';
import './tecnico.dart';
import './alocacao_tecnico.dart';
import './peca.dart';
import './requisicao_peca.dart';
import './item_requisicao.dart';
import './destino_sustentavel.dart';
import './residuo.dart';

void main() {
  print("=== INICIANDO BATERIA DE TESTES DAS CLASSES ===\n");

  //Teste 1: Cadastro base (Cliente e Fazenda)
  var cliente = Cliente(
    idCliente: 1,
    nome: "Agropecuária Teste",
    documento: "01.001.001/0001-01",
  );

  var fazenda = Fazenda(
    idFazenda: 10,
    idCliente: cliente.idCliente!,
    nome: "Fazenda Teste",
  );

  assert(
    fazenda.idCliente == cliente.idCliente,
    "[ERRO] Fazenda desconectada do cliente",
  );
  print("Teste 1 [OK]: Cliente e Fazenda vinculados");

  //Teste 2: Maquinario e Ordem de Serviço
  var trator = Maquinario(
    idMaquinario: 100,
    idFazenda: fazenda.idFazenda!,
    descricao: "Trator MF 4292",
    horimetroAtual: 2540,
    //Deve assumir status 'Ativo' por padrão
  );

  var os = OrdemServico(
    idOrdemServico: 500,
    idMaquinario: trator.idMaquinario!,
    tipo: "Preventiva",
    dataAbertura: DateTime.now(),
    horimetroMomento: 2540,
    pendenciaAmbiental: true,
  );

  assert(
    trator.status == "Ativo",
    "[ERRO] Status padrão do maquinário incorreto",
  );
  assert(os.status == "Aberta", "[ERRO] Status padrão da OS incorreto");
  print("Teste 2 [OK]: Maquinário e OS criados com valores padrões corretos");

  //Teste 3: Alocação de Técnico
  var tecnico = Tecnico(idTecnico: 5, nome: "João");

  var alocacao = AlocacaoTecnico(
    idAlocacaoTecnico: 1,
    idOrdemServico: os.idOrdemServico!,
    idTecnico: tecnico.idTecnico!,
    dataAlocacao: DateTime.now(),
    horaInicio: "8:00",
    horaFim: "12:00",
    funcao: "Mecânico Principal",
  );

  assert(
    alocacao.idTecnico == tecnico.idTecnico,
    "[ERRO] Técnico não associado",
  );
  print("Teste 3 [OK]: Técnico alocado a OS");

  //Teste 4: Requisição de Peças e Cálculo de Itens
  var peca = Peca(
    idPeca: 30,
    descricao: 'Filtro de Óleo Lubrificante',
    tipo: 'Filtro',
    unidadeMedida: 'UN',
  );

  var requisicao = RequisicaoPeca(
    idRequisicaoPeca: 80,
    idOrdemServico: os.idOrdemServico!,
    dataRequisicao: DateTime.now(),
  );

  var item = ItemRequisicao(
    idItemRequisicao: 1,
    idRequisicaoPeca: requisicao.idRequisicaoPeca!,
    idPeca: peca.idPeca!,
    quantidade: 2.0,
    precoUnitario: 85.50,
  );

  double subtotalCalculado = item.quantidade * item.precoUnitario;
  assert(
    subtotalCalculado == 171.0,
    'Erro: Cálculo de subtotal do item falhou',
  );
  print(
    'Teste 4 [OK]: Requisição de peças e cálculo de subtotal (R\$ $subtotalCalculado).',
  );

  //Teste 5: Destino Sustentável e Resíduo Ambiental
  var empresaEmpress = DestinoSustentavel(
    idDestinoSustentavel: 2,
    empresaLicenciada: 'EcoRecicla Teste',
    cnpj: '10.100.100/0001-10',
    licencaAmbiental: 'LA-2026-0001',
  );

  var residuo = Residuo(
    idResiduo: 1,
    idOrdemServico: os.idOrdemServico!,
    idDestinoSustentavel: empresaEmpress.idDestinoSustentavel!,
    tipo: 'Óleo Lubrificante Usado',
    quantidade: 15.0, // Litros
    dataGeracao: DateTime.now(),
  );

  assert(
    residuo.idDestinoSustentavel == empresaEmpress.idDestinoSustentavel,
    'Erro: Resíduo sem licença válida',
  );
  print('Teste 5 [OK]: Descarte de resíduo vinculado à empresa licenciada.');
}
