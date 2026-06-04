import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/ordem_model.dart';
import 'nova_ordem_screen.dart';
import 'ordem_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Box box = Hive.box('ordens');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GtechCell Assistência Técnica'),
        backgroundColor: Colors.blue[800],
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('Nenhuma ordem cadastrada ainda'));
          }

          final ordens = box.values
              .map((e) => Ordem.fromJson(Map<String, dynamic>.from(e)))
              .toList()
            ..sort((a, b) => b.data.compareTo(a.data));

          return ListView.builder(
            itemCount: ordens.length,
            itemBuilder: (context, index) {
              final ordem = ordens[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.blue[700], child: Text((index + 1).toString())),
                  title: Text(ordem.cliente),
                  subtitle: Text('\( {ordem.data.day}/ \){ordem.data.month}/${ordem.data.year} - R\$ ${ordem.valorTotal.toStringAsFixed(2)}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrdemDetailScreen(ordem: ordem))),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NovaOrdemScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
