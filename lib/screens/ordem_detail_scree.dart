import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../models/ordem_model.dart';

class NovaOrdemScreen extends StatefulWidget {
  const NovaOrdemScreen({super.key});

  @override
  State<NovaOrdemScreen> createState() => _NovaOrdemScreenState();
}

class _NovaOrdemScreenState extends State<NovaOrdemScreen> {
  final _formKey = GlobalKey<FormState>();

  final clienteCtrl = TextEditingController();
  final cpfCtrl = TextEditingController();
  final enderecoCtrl = TextEditingController();
  final telefoneCtrl = TextEditingController();
  final descricaoCtrl = TextEditingController();

  List<String> checklist = [];
  List<Map<String, dynamic>> servicos = [];
  final itemChecklistCtrl = TextEditingController();
  final servicoCtrl = TextEditingController();
  final valorCtrl = TextEditingController();

  double valorTotal = 0.0;

  final cpfFormatter = MaskTextInputFormatter(mask: '###.###.###-##', filter: {"#": RegExp(r'[0-9]')});
  final telefoneFormatter = MaskTextInputFormatter(mask: '(##) #####-####', filter: {"#": RegExp(r'[0-9]')});

  String? validarCPF(String? value) {
    if (value == null || value.isEmpty) return 'CPF é obrigatório';
    String cpf = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cpf.length != 11) return 'CPF deve ter 11 dígitos';
    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) return 'CPF inválido';

    int soma = 0;
    for (int i = 0; i < 9; i++) soma += int.parse(cpf[i]) * (10 - i);
    int resto = soma % 11;
    int digito1 = resto < 2 ? 0 : 11 - resto;

    soma = 0;
    for (int i = 0; i < 9; i++) soma += int.parse(cpf[i]) * (11 - i);
    soma += digito1 * 2;
    resto = soma % 11;
    int digito2 = resto < 2 ? 0 : 11 - resto;

    if (digito1 != int.parse(cpf[9]) || digito2 != int.parse(cpf[10])) return 'CPF inválido';
    return null;
  }

  void adicionarChecklist() {
    if (itemChecklistCtrl.text.isNotEmpty) {
      setState(() {
        checklist.add(itemChecklistCtrl.text);
        itemChecklistCtrl.clear();
      });
    }
  }

  void adicionarServico() {
    if (servicoCtrl.text.isNotEmpty && valorCtrl.text.isNotEmpty) {
      final valor = double.tryParse(valorCtrl.text) ?? 0;
      setState(() {
        servicos.add({'descricao': servicoCtrl.text, 'valor': valor});
        valorTotal += valor;
        servicoCtrl.clear();
        valorCtrl.clear();
      });
    }
  }

  void salvarOrdem() async {
    if (_formKey.currentState!.validate() && servicos.isNotEmpty) {
      final ordem = Ordem(
        cliente: clienteCtrl.text,
        cpf: cpfCtrl.text,
        endereco: enderecoCtrl.text,
        telefone: telefoneCtrl.text,
        descricao: descricaoCtrl.text,
        checklist: checklist,
        servicos: servicos,
        valorTotal: valorTotal,
        data: DateTime.now(),
      );

      await Hive.box('ordens').put(ordem.id, ordem.toJson());
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ordem salva com sucesso!')));
    } else if (servicos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Adicione pelo menos um serviço')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Ordem de Serviço')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(controller: clienteCtrl, decoration: const InputDecoration(labelText: 'Nome do Cliente *'), validator: (v) => v!.isEmpty ? 'Obrigatório' : null),
              TextFormField(controller: cpfCtrl, decoration: const InputDecoration(labelText: 'CPF *'), inputFormatters: [cpfFormatter], validator: validarCPF),
              TextFormField(controller: telefoneCtrl, decoration: const InputDecoration(labelText: 'Telefone'), inputFormatters: [telefoneFormatter]),
              TextFormField(controller: enderecoCtrl, decoration: const InputDecoration(labelText: 'Endereço')),
              TextFormField(controller: descricaoCtrl, decoration: const InputDecoration(labelText: 'Descrição do Serviço'), maxLines: 3),

              const SizedBox(height: 20),
              const Text('Checklist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(children: [Expanded(child: TextField(controller: itemChecklistCtrl, decoration: const InputDecoration(hintText: 'Adicionar item'))), IconButton(onPressed: adicionarChecklist, icon: const Icon(Icons.add))]),
              ...checklist.map((item) => ListTile(leading: const Icon(Icons.check), title: Text(item))),

              const SizedBox(height: 20),
              const Text('Serviços / Produtos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(children: [
                Expanded(child: TextField(controller: servicoCtrl, decoration: const InputDecoration(hintText: 'Descrição'))),
                Expanded(child: TextField(controller: valorCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Valor R\$'))),
                IconButton(onPressed: adicionarServico, icon: const Icon(Icons.add)),
              ]),
              ...servicos.map((s) => ListTile(title: Text(s['descricao']), trailing: Text('R\$ ${s['valor'].toStringAsFixed(2)}'))),

              const SizedBox(height: 30),
              Text('Valor Total: R\$ ${valorTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),

              const SizedBox(height: 30),
              SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: salvarOrdem, child: const Text('Salvar Ordem', style: TextStyle(fontSize: 18)))),
            ],
          ),
        ),
      ),
    );
  }
}
