import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/ordem_model.dart';
import 'package:intl/intl.dart';

class PdfGenerator {
  static Future<void> gerarCupom80mm(Ordem ordem) async {
    final pdf = pw.Document();
    final formatador = DateFormat('dd/MM/yyyy HH:mm');

    final ByteData logoData = await rootBundle.load('assets/images/logo.png');
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    final pw.MemoryImage logoImage = pw.MemoryImage(logoBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(300, 820),
        margin: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Center(child: pw.Image(logoImage, width: 135, height: 65)),
              pw.SizedBox(height: 6),
              pw.Text('GtechCell Assistência Técnica', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
              pw.Text('Celulares e Acessórios', style: const pw.TextStyle(fontSize: 10)),
              pw.Divider(thickness: 1.2),
              pw.SizedBox(height: 10),

              pw.Text('ORDEM DE SERVIÇO', style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold)),
              pw.Text('Data: ${formatador.format(ordem.data)}'),
              pw.Text('OS #: ${ordem.id.substring(0, 8).toUpperCase()}'),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 12),

              pw.Align(alignment: pw.Alignment.centerLeft, child: pw.Text('Cliente: ${ordem.cliente}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12))),
              if (ordem.cpf.isNotEmpty) pw.Align(alignment: pw.Alignment.centerLeft, child: pw.Text('CPF: ${ordem.cpf}')),
              pw.Align(alignment: pw.Alignment.centerLeft, child: pw.Text('Telefone: ${ordem.telefone}')),
              if (ordem.endereco.isNotEmpty) pw.Align(alignment: pw.Alignment.centerLeft, child: pw.Text('End.: ${ordem.endereco}')),

              pw.SizedBox(height: 15),

              if (ordem.descricao.isNotEmpty) ...[
                pw.Text('Descrição:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(ordem.descricao),
                pw.SizedBox(height: 12),
              ],

              if (ordem.checklist.isNotEmpty) ...[
                pw.Text('CHECKLIST:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ...ordem.checklist.map((item) => pw.Align(alignment: pw.Alignment.centerLeft, child: pw.Text('✓ $item'))),
                pw.SizedBox(height: 12),
              ],

              pw.Text('SERVIÇOS / PRODUTOS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Divider(thickness: 0.5),

              ...ordem.servicos.map((s) => pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Expanded(child: pw.Text(s['descricao'])), pw.Text('R\$ ${s['valor'].toStringAsFixed(2)}')])),

              pw.Divider(thickness: 1),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text('TOTAL', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text('R\$ ${ordem.valorTotal.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              ]),

              pw.SizedBox(height: 20),
              pw.Text('QR Code - Ordem de Serviço', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: ordem.id,
                  width: 110,
                  height: 110,
                ),
              ),

              pw.SizedBox(height: 15),
              pw.Center(child: pw.Text('Obrigado pela preferência!', style: const pw.TextStyle(fontSize: 11))),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save(), name: 'OS_${ordem.id.substring(0, 8)}');
  }
}
