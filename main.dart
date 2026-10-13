import 'dart:io';

// Importação dos 12 Modelos de Domínio
import 'models/alocacao_tecnico.dart';
import 'models/cliente.dart';
import 'models/destino_sustentavel.dart';
import 'models/especialidade.dart';
import 'models/fazenda.dart';
import 'models/item_requisicao.dart';
import 'models/maquinario.dart';
import 'models/ordem_servico.dart';
import 'models/peca.dart';
import 'models/peca_instalada.dart';
import 'models/requisicao_peca.dart';
import 'models/residuo.dart';
import 'models/tecnico.dart';

// Repositórios MySQL
import 'repositories/cliente_repository_mysql.dart';
import 'repositories/fazenda_repository_mysql.dart';
import 'repositories/maquinario_repository_mysql.dart';
import 'repositories/ordem_servico_repository_mysql.dart';
import 'repositories/destino_sustentavel_repository_mysql.dart';
import 'repositories/residuo_repository_mysql.dart';
import 'repositories/tecnico_repository_mysql.dart';
import 'repositories/peca_repository_mysql.dart';
import 'repositories/alocacao_tecnico_repository_mysql.dart';
import 'repositories/requisicao_peca_repository_mysql.dart';
import 'repositories/estoque_repository_mysql.dart';
import 'repositories/peca_instalada_repository_mysql.dart';
import 'repositories/especialidade_repository_mysql.dart';

// Serviços
import 'services/cliente_service.dart';
import 'services/ordem_servico_service.dart';
import 'services/destino_sustentavel_service.dart';

// Exceções
import 'exceptions/horimetro_invalido_exception.dart';
import 'exceptions/licenca_ambiental_exception.dart';
import 'exceptions/maquinario_inativo_exception.dart';
import 'exceptions/regra_negocio_exception.dart';

void main() async {
  final clienteRepo = ClienteRepositoryMysql();
  final fazendaRepo = FazendaRepositoryMysql();
  final maquinarioRepo = MaquinarioRepositoryMysql();
  final osRepo = OrdemServicoRepositoryMysql();
  final destinoRepo = DestinoSustentavelRepositoryMysql();
  final residuoRepo = ResiduoRepositoryMysql();
  final tecnicoRepo = TecnicoRepositoryMysql();
  final pecaRepo = PecaRepositoryMysql();
  final alocacaoRepo = AlocacaoTecnicoRepositoryMysql();
  final requisicaoRepo = RequisicaoPecaRepositoryMysql();
  final estoqueRepo = EstoqueRepositoryMysql();
  final pecaInstaladaRepo = PecaInstaladaRepositoryMysql();
  final especialidadeRepo = EspecialidadeRepositoryMysql();

  final clienteService = ClienteService(clienteRepo);
  final osService = OrdemServicoService(osRepo, maquinarioRepo);
  final destinoService = DestinoSustentavelService();

  bool executando = true;

  while (executando) {
    print('\n==================================================================');
    print('          AGROFLEET - GESTÃO DE MANUTENÇÃO E SUSTENTABILIDADE     ');
    print('==================================================================');
    print('1. Módulo de Cadastros Base & Estoque');
    print('2. Módulo de Ordens de Serviço & Reconciliação de Estoque');
    print('3. Módulo de Sustentabilidade & Logística Reversa (ODS 12)');
    print('4. Módulo de Consulta de Registros no Banco');
    print('0. Sair');
    print('------------------------------------------------------------------');
    
    final opcao = _lerTextoObrigatorio('[ENTRADA] Selecione uma opção: ');

    try {
      switch (opcao) {
        case '1':
          await _menuCadastros(clienteService, clienteRepo, fazendaRepo, maquinarioRepo, tecnicoRepo, pecaRepo, estoqueRepo, especialidadeRepo);
          break;
        case '2':
          await _menuOrdensServico(osService, osRepo, maquinarioRepo, tecnicoRepo, alocacaoRepo, pecaRepo, requisicaoRepo, estoqueRepo, pecaInstaladaRepo, residuoRepo);
          break;
        case '3':
          await _menuSustentabilidade(destinoService, destinoRepo, osRepo, residuoRepo);
          break;
        case '4':
          await _menuConsultas(clienteRepo, fazendaRepo, maquinarioRepo, tecnicoRepo, pecaRepo, osRepo, destinoRepo, residuoRepo);
          break;
        case '0':
          executando = false;
          print('\n[INFO] Encerrando o sistema AgroFleet...');
          break;
        default:
          print('[ERRO] Opção inválida. Digite um número do menu.');
      }
    } on RegraNegocioException catch (e) {
      print('\n[REGRA DE NEGÓCIO VIOLADA]: $e');
    } catch (e) {
      print('\n[ERRO DE SISTEMA]: $e');
    }
  }
}

// =============================================================================
// HELPERS DE ENTRADA PADRONIZADOS
// =============================================================================

String _lerTextoObrigatorio(String mensagem) {
  while (true) {
    stdout.write(mensagem);
    final entrada = stdin.readLineSync()?.trim() ?? '';
    if (entrada.isNotEmpty) return entrada;
    print('[ERRO] Campo obrigatório. Por favor, informe um valor.');
  }
}

String? _lerTextoOpcional(String mensagem) {
  stdout.write('$mensagem (Opção em branco = Nulo): ');
  final entrada = stdin.readLineSync()?.trim() ?? '';
  return entrada.isEmpty ? null : entrada;
}

int _lerIntObrigatorio(String mensagem) {
  while (true) {
    stdout.write(mensagem);
    final entrada = stdin.readLineSync()?.trim() ?? '';
    final valor = int.tryParse(entrada);
    if (valor != null) return valor;
    print('[ERRO] Digite um número inteiro válido.');
  }
}

int? _lerIntOpcional(String mensagem) {
  stdout.write('$mensagem (Opção em branco = Nulo): ');
  final entrada = stdin.readLineSync()?.trim() ?? '';
  if (entrada.isEmpty) return null;
  return int.tryParse(entrada);
}

double _lerDoubleObrigatorio(String mensagem) {
  while (true) {
    stdout.write(mensagem);
    final entrada = stdin.readLineSync()?.trim().replaceAll(',', '.') ?? '';
    final valor = double.tryParse(entrada);
    if (valor != null) return valor;
    print('[ERRO] Digite um valor numérico válido (ex: 15.50).');
  }
}

double? _lerDoubleOpcional(String mensagem) {
  stdout.write('$mensagem (Opção em branco = Nulo): ');
  final entrada = stdin.readLineSync()?.trim().replaceAll(',', '.') ?? '';
  if (entrada.isEmpty) return null;
  return double.tryParse(entrada);
}

// =============================================================================
// SUBMENUS DO SISTEMA
// =============================================================================

Future<void> _menuCadastros(
  ClienteService clienteService,
  ClienteRepositoryMysql clienteRepo,
  FazendaRepositoryMysql fazendaRepo,
  MaquinarioRepositoryMysql maquinarioRepo,
  TecnicoRepositoryMysql tecnicoRepo,
  PecaRepositoryMysql pecaRepo,
  EstoqueRepositoryMysql estoqueRepo,
  EspecialidadeRepositoryMysql espRepo,
) async {
  print('\n------------------------------------------------------------------');
  print('                    MÓDULO DE CADASTROS BASE                      ');
  print('------------------------------------------------------------------');
  print('1. Cadastrar Cliente');
  print('2. Cadastrar Fazenda');
  print('3. Cadastrar Maquinário');
  print('4. Cadastrar Técnico (+Especialidade)');
  print('5. Cadastrar Peça & Saldo em Estoque');
  final op = _lerTextoObrigatorio('[ENTRADA] Selecione uma opção: ');

  if (op == '1') {
    print('\n[ NOVO CLIENTE ]');
    final nome = _lerTextoObrigatorio('Nome / Razão Social (*Obrigatório): ');
    final doc = _lerTextoObrigatorio('CPF ou CNPJ (*Obrigatório): ');
    final tel = _lerTextoOpcional('Telefone / Celular');
    final email = _lerTextoOpcional('E-mail');

    final c = await clienteService.cadastrarCliente(
      Cliente(nome: nome, documento: doc, telefone: tel, email: email),
    );
    print('[OK] Cliente cadastrado com sucesso! ID: #${c.idCliente}');

  } else if (op == '2') {
    print('\n[ NOVA FAZENDA ]');
    final idCliente = _lerIntObrigatorio('ID do Cliente Proprietário (*Obrigatório): ');
    
    final cCheck = await clienteRepo.executarQuery(
      'SELECT idCliente FROM cliente WHERE idCliente = ?',
      [idCliente],
    );
    if (cCheck.isEmpty) {
      print('[ERRO] Cliente ID #$idCliente não encontrado no banco de dados. Cadastre o cliente primeiro.');
      return;
    }

    final nome = _lerTextoObrigatorio('Nome da Fazenda (*Obrigatório): ');
    final endereco = _lerTextoOpcional('Endereço');
    final cidade = _lerTextoOpcional('Cidade');
    final estado = _lerTextoOpcional('Estado (UF)');

    final f = await fazendaRepo.salvar(
      Fazenda(idCliente: idCliente, nome: nome, endereco: endereco, cidade: cidade, estado: estado),
    );
    print('[OK] Fazenda cadastrada com sucesso! ID: #${f.idFazenda}');

  } else if (op == '3') {
    print('\n[ NOVO MAQUINÁRIO ]');
    final idFazenda = _lerIntObrigatorio('ID da Fazenda (*Obrigatório): ');
    
    final fazendaExistente = await fazendaRepo.buscarPorId(idFazenda);
    if (fazendaExistente == null) {
      print('[ERRO] Fazenda ID #$idFazenda não encontrada no banco de dados. Cadastre a fazenda primeiro.');
      return;
    }

    final desc = _lerTextoObrigatorio('Descrição do Equipamento (*Obrigatório): ');
    final modelo = _lerTextoOpcional('Modelo');
    final marca = _lerTextoOpcional('Marca');
    final ano = _lerIntOpcional('Ano de Fabricação');
    final horimetro = _lerDoubleOpcional('Horímetro Atual Medido') ?? 0.0;
    final dtAquisicaoStr = _lerTextoOpcional('Data de Aquisição (AAAA-MM-DD)');
    DateTime? dtAquisicao = dtAquisicaoStr != null ? DateTime.tryParse(dtAquisicaoStr) : null;

    final m = await maquinarioRepo.salvar(
      Maquinario(
        idFazenda: idFazenda,
        descricao: desc,
        modelo: modelo,
        marca: marca,
        anoFabricacao: ano,
        horimetroAtual: horimetro,
        dataAquisicao: dtAquisicao,
        status: 'Ativo',
      ),
    );
    print('[OK] Maquinário cadastrado com sucesso! ID: #${m.idMaquinario}');

  } else if (op == '4') {
    print('\n[ NOVO TÉCNICO ]');
    final nome = _lerTextoObrigatorio('Nome do Técnico (*Obrigatório): ');
    final valorHora = _lerDoubleObrigatorio('Valor da Hora Trabalhada R\$ (*Obrigatório): ');
    final tel = _lerTextoOpcional('Telefone');
    final email = _lerTextoOpcional('E-mail');

    final t = await tecnicoRepo.salvar(
      Tecnico(nome: nome, valorHora: valorHora, telefone: tel, email: email, ativo: true),
    );

    final espNome = _lerTextoOpcional('Especialidade Principal (ex: Mecânica Diesel, Elétrica)');
    if (espNome != null && espNome.isNotEmpty) {
      final descEsp = _lerTextoOpcional('Descrição da Especialidade');
      final idEsp = await espRepo.cadastrarOuBuscarEspecialidade(espNome, descEsp);
      await espRepo.vincularEspecialidade(t.idTecnico!, idEsp);
      print('[OK] Especialidade "$espNome" associada ao Técnico ID #${t.idTecnico}.');
    }
    print('[OK] Técnico cadastrado com sucesso! ID: #${t.idTecnico}');

  } else if (op == '5') {
    print('\n[ NOVA PEÇA E ESTOQUE ]');
    final desc = _lerTextoObrigatorio('Descrição da Peça (*Obrigatório): ');
    print('Tipos aceitos pelo banco: Estrutural, Consumivel');
    final tipo = _lerTextoObrigatorio('Tipo (*Obrigatório): ');
    final vidaUtil = _lerDoubleOpcional('Vida Útil Estimada em Horas');
    final un = _lerTextoOpcional('Unidade de Medida (UN, L, KG)') ?? 'UN';

    final p = await pecaRepo.salvar(
      Peca(descricao: desc, tipo: tipo, vidaUtilHorimetro: vidaUtil, unidadeMedida: un),
    );

    final qtdEstoque = _lerDoubleObrigatorio('Saldo Inicial em Estoque (*Obrigatório): ');
    final nivelMinimo = _lerDoubleOpcional('Nível Mínimo para Alerta') ?? 0.0;
    final loc = _lerTextoOpcional('Localização no Almoxarifado');

    await estoqueRepo.salvarOuAtualizar(p.idPeca!, qtdEstoque, nivelMinimo, loc ?? 'Almoxarifado');
    print('[OK] Peça ID #${p.idPeca} e Estoque salvos com sucesso!');
  }
}

Future<void> _menuOrdensServico(
  OrdemServicoService osService,
  OrdemServicoRepositoryMysql osRepo,
  MaquinarioRepositoryMysql maquinarioRepo,
  TecnicoRepositoryMysql tecnicoRepo,
  AlocacaoTecnicoRepositoryMysql alocacaoRepo,
  PecaRepositoryMysql pecaRepo,
  RequisicaoPecaRepositoryMysql requisicaoRepo,
  EstoqueRepositoryMysql estoqueRepo,
  PecaInstaladaRepositoryMysql pecaInstaladaRepo,
  ResiduoRepositoryMysql residuoRepo,
) async {
  print('\n------------------------------------------------------------------');
  print('            MÓDULO DE ORDENS DE SERVIÇO & ESTOQUE                 ');
  print('------------------------------------------------------------------');
  print('1. Abrir Nova Ordem de Serviço');
  print('2. Alocar Técnico na OS');
  print('3. Requisitar Peça (Baixa Provisória no Estoque)');
  print('4. Concluir OS (Confirmar Peças Instaladas & Registrar Resíduos Gerados)');
  final op = _lerTextoObrigatorio('[ENTRADA] Selecione uma opção: ');

  if (op == '1') {
    print('\n[ ABERTURA DE OS ]');
    final idMaq = _lerIntObrigatorio('ID do Maquinário (*Obrigatório): ');
    
    final maquinario = await maquinarioRepo.buscarPorId(idMaq);
    if (maquinario == null) {
      print('[ERRO] Maquinário ID #$idMaq não encontrado no banco de dados. Cadastre o maquinário primeiro.');
      return;
    }

    print('Tipos aceitos pelo banco: Preventiva, Corretiva');
    final tipo = _lerTextoObrigatorio('Tipo de Serviço (*Obrigatório): ');
    final horimetro = _lerDoubleObrigatorio('Horímetro Medido na Abertura (*Obrigatório): ');
    final obs = _lerTextoOpcional('Observações');

    final os = await osService.abrirOrdemServico(
      idMaquinario: idMaq,
      tipo: tipo,
      horimetroInformado: horimetro,
      observacao: obs,
    );
    print('[OK] OS #${os.idOrdemServico} aberta com sucesso!');

  } else if (op == '2') {
    print('\n[ ALOCAÇÃO DE TÉCNICO ]');
    final idOS = _lerIntObrigatorio('ID da OS (*Obrigatório): ');
    
    final os = await osRepo.buscarPorId(idOS);
    if (os == null) {
      print('[ERRO] Ordem de Serviço ID #$idOS não encontrada no banco de dados.');
      return;
    }

    final idTec = _lerIntObrigatorio('ID do Técnico (*Obrigatório): ');
    final tec = await tecnicoRepo.buscarPorId(idTec);
    if (tec == null) {
      print('[ERRO] Técnico ID #$idTec não encontrado no banco de dados.');
      return;
    }

    final funcao = _lerTextoOpcional('Função Desempenhada');
    final hInicio = _lerTextoOpcional('Hora Início (HH:MM:SS)') ?? '08:00:00';
    final hFim = _lerTextoOpcional('Hora Fim (HH:MM:SS)') ?? '12:00:00';

    await alocacaoRepo.salvar(
      AlocacaoTecnico(
        idOrdemServico: idOS,
        idTecnico: idTec,
        dataAlocacao: DateTime.now(),
        horaInicio: hInicio,
        horaFim: hFim,
        funcao: funcao ?? 'Manutenção',
      ),
    );
    print('[OK] Técnico ID #$idTec alocado na OS #$idOS com sucesso!');

  } else if (op == '3') {
    print('\n[ REQUISIÇÃO DE PEÇAS ]');
    final idOS = _lerIntObrigatorio('ID da OS (*Obrigatório): ');
    
    final os = await osRepo.buscarPorId(idOS);
    if (os == null) {
      print('[ERRO] Ordem de Serviço ID #$idOS não encontrada no banco. Abra a OS no Menu 2 -> Opção 1.');
      return;
    }

    final fin = _lerTextoOpcional('Finalidade da Requisição');

    final req = await requisicaoRepo.salvar(
      RequisicaoPeca(idOrdemServico: idOS, dataRequisicao: DateTime.now(), finalidade: fin),
    );

    final idPeca = _lerIntObrigatorio('ID da Peça (*Obrigatório): ');
    final qtdReq = _lerDoubleObrigatorio('Quantidade Requisitada (*Obrigatório): ');
    final precoUnit = _lerDoubleOpcional('Preço Unitário R\$') ?? 0.0;

    final saldoAtual = await estoqueRepo.buscarSaldoAtual(idPeca);
    if (saldoAtual < qtdReq) {
      print('[ERRO] Saldo insuficiente no estoque (Disponível: $saldoAtual). Requisição não efetuada.');
      return;
    }

    await requisicaoRepo.adicionarItem(
      ItemRequisicao(
        idRequisicaoPeca: req.idRequisicaoPeca!,
        idPeca: idPeca,
        quantidade: qtdReq,
        precoUnitario: precoUnit,
      ),
    );

    await estoqueRepo.darBaixaEstoque(idPeca, qtdReq);
    print('[OK] Requisição gravada e $qtdReq unidades reservadas no estoque!');

  } else if (op == '4') {
    print('\n[ FECHAMENTO E CONCLUSAO DE OS ]');
    final idOS = _lerIntObrigatorio('ID da OS a Concluir (*Obrigatório): ');
    final os = await osRepo.buscarPorId(idOS);
    if (os == null) {
      print('[ERRO] OS #$idOS não encontrada.');
      return;
    }

    // Reconciliação de Peças e Estoque
    final items = await requisicaoRepo.executarQuery(
      'SELECT ir.idItemRequisicao, ir.idPeca, ir.Quantidade FROM itemrequisicao ir JOIN requisicaopeca rp ON ir.idRequisicaoPeca = rp.idRequisicaoPeca WHERE rp.idOrdemServico = ?',
      [idOS],
    );

    for (var row in items) {
      final idItem = row['idItemRequisicao'] as int;
      final idP = row['idPeca'] as int;
      final qtdReservada = (row['Quantidade'] as num).toDouble();

      final qtdInstalada = _lerDoubleObrigatorio('Qtd efetivamente instalada da Peça ID #$idP (Reservada: $qtdReservada): ');

      if (qtdInstalada < qtdReservada) {
        final sobra = qtdReservada - qtdInstalada;
        await estoqueRepo.estornarEstoque(idP, sobra);
        print('  -> Estorno de $sobra unidades efetuado de volta ao estoque.');

        await requisicaoRepo.executarQuery(
          'UPDATE itemrequisicao SET Quantidade = ? WHERE idItemRequisicao = ?',
          [qtdInstalada, idItem],
        );
      }

      if (qtdInstalada > 0) {
        await pecaInstaladaRepo.registrarInstalacao(
          idMaquinario: os.idMaquinario,
          idPeca: idP,
          horimetroInstalacao: os.horimetroMomento,
          idOrdemServicoInstalacao: idOS,
        );
      }
    }

    // Registro Detalhado de Resíduos Gerados na OS
    final gerouResiduo = _lerTextoOpcional('Esta manutenção gerou resíduos no local? (S/N)');
    if (gerouResiduo != null && gerouResiduo.toUpperCase() == 'S') {
      bool cadastrandoResiduos = true;

      while (cadastrandoResiduos) {
        print('\n  [ REGISTRO DE RESÍDUO GERADO ]');
        print('  Tipos aceitos pelo banco: Oleo, Filtro, Sucata, Outro');
        final tipo = _lerTextoObrigatorio('  Tipo de Resíduo (*Obrigatório): ');
        final qtd = _lerDoubleObrigatorio('  Quantidade Gerada (*Obrigatório): ');
        final obs = _lerTextoOpcional('  Observações sobre o resíduo');

        await residuoRepo.salvar(
          Residuo(
            idOrdemServico: idOS,
            tipo: tipo,
            quantidade: qtd,
            dataGeracao: DateTime.now(),
            observacao: obs,
            status: 'Pendente',
          ),
        );
        print('  [OK] Resíduo "$tipo" ($qtd) registrado na base para a OS #$idOS com status PENDENTE.');

        final maisResiduo = _lerTextoOpcional('\n  Deseja registrar mais algum outro tipo de resíduo para esta OS? (S/N)');
        if (maisResiduo == null || maisResiduo.toUpperCase() != 'S') {
          cadastrandoResiduos = false;
        }
      }

      os.pendenciaAmbiental = true;
      print('\n[ATENÇÃO] A OS foi concluída e gravada com PENDÊNCIA AMBIENTAL ATIVA (1) no MySQL.');
    }

    await osService.concluirOrdemServico(idOS);
    print('[OK] OS #$idOS concluída com sucesso!');
  }
}

Future<void> _menuSustentabilidade(
  DestinoSustentavelService destinoService,
  DestinoSustentavelRepositoryMysql destinoRepo,
  OrdemServicoRepositoryMysql osRepo,
  ResiduoRepositoryMysql residuoRepo,
) async {
  print('\n------------------------------------------------------------------');
  print('              MÓDULO DE SUSTENTABILIDADE & ODS 12                 ');
  print('------------------------------------------------------------------');
  print('1. Cadastrar Destino Licenciado (Empresa Receptora)');
  print('2. Registrar Descarte de Resíduo & Baixar Pendência Ambiental');
  final op = _lerTextoObrigatorio('[ENTRADA] Selecione uma opção: ');

  if (op == '1') {
    print('\n[ CADASTRO DE DESTINO LICENCIADO ]');
    final nome = _lerTextoObrigatorio('Razão Social (*Obrigatório): ');
    final cnpj = _lerTextoObrigatorio('CNPJ (*Obrigatório): ');
    final lic = _lerTextoObrigatorio('Número da Licença Ambiental (*Obrigatório): ');
    final dtValidadeStr = _lerTextoObrigatorio('Data de Validade da Licença (AAAA-MM-DD) (*Obrigatório): ');

    final dtValidade = DateTime.tryParse(dtValidadeStr);
    if (dtValidade == null) {
      print('[ERRO] Data de validade inválida. Digite no formato AAAA-MM-DD (ex: 2026-12-31).');
      return;
    }

    final tel = _lerTextoOpcional('Telefone');
    final end = _lerTextoOpcional('Endereço');

    final d = DestinoSustentavel(
      empresaLicenciada: nome,
      cnpj: cnpj,
      licencaAmbiental: lic,
      telefone: tel,
      endereco: end,
    );

    // Validação completa de Licença Ativa e CNPJ na Receita Federal via BrasilAPI
    await destinoService.validarECadastrarDestino(d, dtValidade);

    final dSalvo = await destinoRepo.salvar(d);
    print('[OK] Empresa receptora cadastrada com sucesso! ID: #${dSalvo.idDestinoSustentavel}');

  } else if (op == '2') {
    print('\n[ REGISTRO DE DESCARTE DE RESÍDUO ]');
    final idOS = _lerIntObrigatorio('ID da OS Geradora (*Obrigatório): ');
    
    final os = await osRepo.buscarPorId(idOS);
    if (os == null) {
      print('[ERRO] Ordem de Serviço ID #$idOS não encontrada no banco.');
      return;
    }

    final pendentes = await residuoRepo.listarPendentesPorOrdemServico(idOS);
    if (pendentes.isEmpty) {
      print('[INFO] A OS #$idOS não possui resíduos pendentes de descarte no banco.');
      return;
    }

    print('\nResíduos Pendentes de Descarte para a OS #$idOS:');
    for (var r in pendentes) {
      print('  ID Resíduo: #${r.idResiduo} | Tipo: ${r.tipo} | Saldo Pendente: ${r.quantidade}');
    }

    final idResiduoEspec = _lerIntObrigatorio('\nDigite o ID do Resíduo que deseja descartar (*Obrigatório): ');
    
    Residuo? resPendente;
    for (var r in pendentes) {
      if (r.idResiduo == idResiduoEspec) {
        resPendente = r;
        break;
      }
    }

    if (resPendente == null) {
      print('[ERRO] ID de resíduo pendente inválido para esta OS.');
      return;
    }

    final idDest = _lerIntObrigatorio('ID da Empresa Receptora Licenciada (*Obrigatório): ');
    final dest = await destinoRepo.buscarPorId(idDest);
    if (dest == null) {
      print('[ERRO] Empresa receptora ID #$idDest não encontrada. Cadastre a receptora na Opção 1.');
      return;
    }

    print('\n  Saldo atual pendente para este item: ${resPendente.quantidade}');
    final qtdDescartar = _lerDoubleObrigatorio('  Quantidade a descartar nesta coleta (*Obrigatório): ');

    if (qtdDescartar <= 0) {
      print('[ERRO] A quantidade descartada deve ser maior que zero.');
      return;
    }

    if (qtdDescartar > resPendente.quantidade) {
      print('[ERRO] A quantidade informada (${qtdDescartar}) é maior do que o saldo pendente (${resPendente.quantidade}).');
      return;
    }

    // Processa o descarte e o cálculo do saldo faltante
    await residuoRepo.registrarDescarte(
      residuoPendente: resPendente,
      qtdDescartada: qtdDescartar,
      idDestinoSustentavel: idDest,
    );

    final saldoFaltante = resPendente.quantidade - qtdDescartar;

    if (saldoFaltante > 0) {
      print('\n[OK] Coleta parcial de $qtdDescartar unidades vinculada à empresa "${dest.empresaLicenciada}".');
      print('[INFO] SALDO FALTANTE A DESCARTAR PARA ESTE ITEM: $saldoFaltante (${resPendente.tipo}).');
    } else {
      print('\n[OK] Descarte TOTAL de ${resPendente.quantidade} unidades registrado para a empresa "${dest.empresaLicenciada}".');
    }

    // Verifica se restou algum resíduo pendente na OS
    final aindaTemPendencia = await residuoRepo.possuiResiduoPendente(idOS);
    if (!aindaTemPendencia) {
      await osRepo.atualizarPendenciaAmbiental(idOS, false);
      print('[OK] TODOS OS RESÍDUOS DA OS #$idOS FORAM DESTINADOS! PENDÊNCIA AMBIENTAL BAIXADA NO MYSQL (0).');
    } else {
      print('[INFO] A OS #$idOS permanece com PENDÊNCIA AMBIENTAL ATIVA (1) referente aos saldos faltantes.');
    }
  }
}

// =============================================================================
// SUBMENU DE CONSULTAS SEPARADAS POR ENTIDADE
// =============================================================================

Future<void> _menuConsultas(
  ClienteRepositoryMysql clienteRepo,
  FazendaRepositoryMysql fazendaRepo,
  MaquinarioRepositoryMysql maquinarioRepo,
  TecnicoRepositoryMysql tecnicoRepo,
  PecaRepositoryMysql pecaRepo,
  OrdemServicoRepositoryMysql osRepo,
  DestinoSustentavelRepositoryMysql destinoRepo,
  ResiduoRepositoryMysql residuoRepo,
) async {
  bool emConsultas = true;

  while (emConsultas) {
    print('\n------------------------------------------------------------------');
    print('                MÓDULO DE CONSULTA DE REGISTROS                   ');
    print('------------------------------------------------------------------');
    print('1. Consultar Clientes');
    print('2. Consultar Fazendas');
    print('3. Consultar Maquinários');
    print('4. Consultar Técnicos & Especialidades');
    print('5. Consultar Peças & Saldo em Estoque');
    print('6. Consultar Ordens de Serviço');
    print('7. Consultar Empresas de Descarte (Destinos Sustentáveis)');
    print('8. Consultar Resíduos Gerados & Status de Descarte');
    print('0. Voltar ao Menu Principal');
    print('------------------------------------------------------------------');

    final subOp = _lerTextoObrigatorio('[ENTRADA] Escolha a tabela para consultar: ');

    switch (subOp) {
      case '1':
        print('\n=== REGISTROS DE CLIENTES ===');
        final res = await clienteRepo.executarQuery(
          'SELECT idCliente, Nome, Documento, Telefone, Email FROM cliente',
        );
        if (res.isEmpty) {
          print('[INFO] Nenhum cliente encontrado no banco de dados.');
        } else {
          for (var r in res) {
            print('ID: #${r['idCliente']} | Nome: ${r['Nome']} | Doc: ${r['Documento']} | Tel: ${r['Telefone'] ?? 'N/A'} | E-mail: ${r['Email'] ?? 'N/A'}');
          }
        }
        break;

      case '2':
        print('\n=== REGISTROS DE FAZENDAS ===');
        final res = await fazendaRepo.executarQuery(
          'SELECT f.idFazenda, f.Nome AS Fazenda, f.Cidade, f.Estado, c.Nome AS Cliente FROM fazenda f JOIN cliente c ON f.idCliente = c.idCliente',
        );
        if (res.isEmpty) {
          print('[INFO] Nenhuma fazenda encontrada no banco de dados.');
        } else {
          for (var r in res) {
            print('ID: #${r['idFazenda']} | Fazenda: ${r['Fazenda']} | Local: ${r['Cidade'] ?? 'N/A'}/${r['Estado'] ?? 'N/A'} | Proprietário: ${r['Cliente']}');
          }
        }
        break;

      case '3':
        print('\n=== REGISTROS DE MAQUINÁRIOS ===');
        final res = await maquinarioRepo.executarQuery(
          'SELECT m.idMaquinario, m.Descricao, m.Marca, m.Modelo, m.HorimetroAtual, m.Status, f.Nome AS Fazenda FROM maquinario m JOIN fazenda f ON m.idFazenda = f.idFazenda',
        );
        if (res.isEmpty) {
          print('[INFO] Nenhum maquinário encontrado no banco de dados.');
        } else {
          for (var r in res) {
            print('ID: #${r['idMaquinario']} | ${r['Descricao']} (${r['Marca'] ?? 'N/A'} ${r['Modelo'] ?? ''}) | Horímetro: ${r['HorimetroAtual']}h | Status: ${r['Status']} | Fazenda: ${r['Fazenda']}');
          }
        }
        break;

      case '4':
        print('\n=== REGISTROS DE TÉCNICOS & ESPECIALIDADES ===');
        final res = await tecnicoRepo.executarQuery(
          '''
          SELECT t.idTecnico, t.Nome, t.Telefone, t.Email, t.ValorHora, t.Ativo, 
                 GROUP_CONCAT(e.Nome SEPARATOR ', ') AS Especialidades 
          FROM tecnico t 
          LEFT JOIN tecnicoespecialidade te ON t.idTecnico = te.idTecnico 
          LEFT JOIN especialidade e ON te.idEspecialidade = e.idEspecialidade 
          GROUP BY t.idTecnico
          ''',
        );
        if (res.isEmpty) {
          print('[INFO] Nenhum técnico encontrado no banco de dados.');
        } else {
          for (var r in res) {
            final ativo = r['Ativo'] == 1 ? 'Ativo' : 'Inativo';
            print('ID: #${r['idTecnico']} | Nome: ${r['Nome']} | R\$ ${r['ValorHora']}/h | Tel: ${r['Telefone'] ?? 'N/A'} | Status: $ativo | Especialidades: ${r['Especialidades'] ?? 'Nenhuma'}');
          }
        }
        break;

      case '5':
        print('\n=== CATÁLOGO DE PEÇAS & SALDO DE ESTOQUE ===');
        final res = await pecaRepo.executarQuery(
          '''
          SELECT p.idPeca, p.Descricao, p.Tipo, p.UnidadeMedida, 
                 COALESCE(e.QuantidadeAtual, 0) AS Estoque, 
                 COALESCE(e.NivelMinimo, 0) AS Minimo, 
                 e.Localizacao 
          FROM peca p 
          LEFT JOIN estoque e ON p.idPeca = e.idPeca
          ''',
        );
        if (res.isEmpty) {
          print('[INFO] Nenhuma peça encontrada no banco de dados.');
        } else {
          for (var r in res) {
            print('ID: #${r['idPeca']} | Peça: ${r['Descricao']} (${r['Tipo']}) | Saldo: ${r['Estoque']} ${r['UnidadeMedida']} | Mínimo: ${r['Minimo']} | Localização: ${r['Localizacao'] ?? 'N/A'}');
          }
        }
        break;

      case '6':
        print('\n=== REGISTROS DE ORDENS DE SERVIÇO ===');
        final res = await osRepo.executarQuery(
          '''
          SELECT os.idOrdemServico, os.Tipo, os.Status, os.DataAbertura, os.HorimetroMomento, 
                 os.PendenciaAmbiental, m.Descricao AS Maquinario 
          FROM ordemservico os 
          JOIN maquinario m ON os.idMaquinario = m.idMaquinario
          ''',
        );
        if (res.isEmpty) {
          print('[INFO] Nenhuma ordem de serviço encontrada no banco de dados.');
        } else {
          for (var r in res) {
            final pendencia = (r['PendenciaAmbiental'] as int) == 1 ? 'ATIVA (1)' : 'QUITADA (0)';
            print('OS ID: #${r['idOrdemServico']} | Tipo: ${r['Tipo']} | Status: ${r['Status']} | Máquina: ${r['Maquinario']} | Horímetro: ${r['HorimetroMomento']}h | Pendência Ambiental: $pendencia');
          }
        }
        break;

      case '7':
        print('\n=== EMPRESAS DE DESCARTE / DESTINOS SUSTENTÁVEIS ===');
        final res = await destinoRepo.executarQuery(
          'SELECT idDestinoSustentavel, EmpresaLicenciada, CNPJ, LicencaAmbiental, Telefone, Endereco FROM destinosustentavel',
        );
        if (res.isEmpty) {
          print('[INFO] Nenhuma empresa de descarte encontrada no banco de dados.');
        } else {
          for (var r in res) {
            print('ID: #${r['idDestinoSustentavel']} | Empresa: ${r['EmpresaLicenciada']} | CNPJ: ${r['CNPJ']} | Licença: ${r['LicencaAmbiental'] ?? 'N/A'} | Tel: ${r['Telefone'] ?? 'N/A'}');
          }
        }
        break;

      case '8':
        print('\n=== REGISTROS DETALHADOS DE RESÍDUOS GERADOS ===');
        final res = await residuoRepo.executarQuery(
          '''
          SELECT r.idResiduo, r.idOrdemServico, r.Tipo, r.Quantidade, r.Status, 
                 COALESCE(d.EmpresaLicenciada, 'Ainda não destinado') AS Receptora 
          FROM residuo r 
          LEFT JOIN destinosustentavel d ON r.idDestinoSustentavel = d.idDestinoSustentavel
          ''',
        );
        if (res.isEmpty) {
          print('[INFO] Nenhum resíduo cadastrado no banco de dados.');
        } else {
          for (var r in res) {
            print('Resíduo ID: #${r['idResiduo']} | OS: #${r['idOrdemServico']} | Tipo: ${r['Tipo']} | Qtd: ${r['Quantidade']} | Status: ${r['Status']} | Destino: ${r['Receptora']}');
          }
        }
        break;

      case '0':
        emConsultas = false;
        break;

      default:
        print('[ERRO] Opção inválida.');
    }
  }
}