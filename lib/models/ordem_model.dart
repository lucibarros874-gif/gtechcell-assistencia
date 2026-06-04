import 'package:uuid/uuid.dart';

class Ordem {
  final String id;
  final String cliente;
  final String cpf;
  final String endereco;
  final String telefone;
  final String descricao;
  final List<String> checklist;
  final List<Map<String, dynamic>> servicos;
  final double valorTotal;
  final DateTime data;

  Ordem({
    String? id,
    required this.cliente,
    required this.cpf,
    required this.endereco,
    required this.telefone,
    required this.descricao,
    required this.checklist,
    required this.servicos,
    required this.valorTotal,
    required this.data,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'cliente': cliente,
        'cpf': cpf,
        'endereco': endereco,
        'telefone': telefone,
        'descricao': descricao,
        'checklist': checklist,
        'servicos': servicos,
        'valorTotal': valorTotal,
        'data': data.toIso8601String(),
      };

  factory Ordem.fromJson(Map<String, dynamic> json) => Ordem(
        id: json['id'],
        cliente: json['cliente'],
        cpf: json['cpf'] ?? '',
        endereco: json['endereco'],
        telefone: json['telefone'],
        descricao: json['descricao'],
        checklist: List<String>.from(json['checklist']),
        servicos: List<Map<String, dynamic>>.from(json['servicos']),
        valorTotal: json['valorTotal'],
        data: DateTime.parse(json['data']),
      );
}
