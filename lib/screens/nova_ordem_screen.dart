import 'package:flutter/material.dart';
import '../models/ordem_model.dart';
import '../utils/pdf_generator.dart';

class OrdemDetailScreen extends StatelessWidget {
  final Ordem ordem;
  const OrdemDetailScreen({super.key, required this.ordem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OS #${ordem.id.substring(0, 8).toUpperCase()}'),
        actions: [IconButton(icon: const Icon(Icons.picture_as_pdf), onPressed: () => PdfGenerator.gerarCupom80mm(ordem))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cliente: ${ordem.cliente}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (ordem.cpf.isNotEmpty) Text('CPF: ${ordem.cpf}'),
              Text('Telefone: ${ordem.telefone}'),
              const SizedBox(height: 16),
              const Text('Checklist:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...ordem.checklist.map((item) => Text('• $item')),
              const SizedBox(height: 16),
              const Text('Serviços:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...ordem.servicos.map((s) => Text('${s['descricao']} - R\$ ${s['valor']}')),
              const SizedBox(height: 30),
              Text('TOTAL: R\$ ${ordem.valorTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
        ),
      ),
    );
  }
}
