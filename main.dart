import 'cliente.dart';
import 'maquinario.dart';
import 'ordemServico.dart';
import 'peca.dart';

void main() {
  var cteste = Cliente(
    idCliente: 1,
    responsavel: "João Manuel",
    nomeFazenda: "Fazenda Boa Vista",
    telefone: "(35) 95685-4321",
  );
  var mteste = Maquinario(
    idMaquinario: 1,
    horimetro: 1250,
    tipo: "Colheitadera",
    modelo: "TC5.30",
    status: "Em manutenção",
  );
  var osteste = OrdemServico(
    idOrdem: 1,
    dataInicio: DateTime(2026, 9, 19),
    status: "Pendente",
    cliente: cteste,
    maquinario: mteste,
  );

  print("===== Ordem de Serviço N° ${osteste.idOrdem} ====");
  print("Status: ${osteste.status}");
  print("Fazenda: ${osteste.cliente.nomeFazenda}");
  print("Responsável: ${osteste.cliente.responsavel}");
  print("Maquinário: ${osteste.maquinario.modelo} (${osteste.maquinario.tipo})",);
  print("Horímetro: ${osteste.maquinario.horimetro}");
}
