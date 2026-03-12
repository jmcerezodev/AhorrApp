import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../local/models/local_history.dart';
import '../../core/shared_preferences/preferences.dart';

class PdfExportService {
  static const PdfColor primaryOrange = PdfColor.fromInt(0xFFFFA500);
  static const PdfColor backgroundCream = PdfColor.fromInt(0xFFFFFBF5);
  static const PdfColor incomeGreen = PdfColor.fromInt(0xFF2E7D32);
  static const PdfColor expenseRed = PdfColor.fromInt(0xFFC62828);

  Future<void> exportFinancialReport(List<LocalHistory> movements, double balance) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        header: (context) => _buildHeader(fontBold),
        footer: (context) => _buildFooter(context, font),
        build: (context) => [
          // Simulamos el fondo crema con un contenedor que envuelva todo el contenido si fuera necesario, 
          // pero para reporte limpio el blanco es estándar. No obstante, aplicamos acentos crema.
          _buildSummaryCard(balance, fontBold),
          pw.SizedBox(height: 20),
          _buildMovementsTable(movements, font, fontBold),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/Reporte_AhorrApp_${DateTime.now().millisecondsSinceEpoch}.pdf");
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'Mi Reporte Financiero de AhorrApp');
  }

  pw.Widget _buildHeader(pw.Font fontBold) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('AhorrApp', style: pw.TextStyle(font: fontBold, fontSize: 24, color: primaryOrange)),
              pw.Text('Reporte Financiero Personal', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(Preferences.name, style: pw.TextStyle(font: fontBold, fontSize: 14)),
              pw.Text(DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()), style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryCard(double balance, pw.Font fontBold) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: backgroundCream,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(15)),
        border: pw.Border.all(color: primaryOrange.flatten(), width: 1),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('BALANCE TOTAL', style: pw.TextStyle(font: fontBold, fontSize: 16)),
          pw.Text(
            '${balance.toStringAsFixed(2)} €',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 20,
              color: balance >= 0 ? incomeGreen : expenseRed,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildMovementsTable(List<LocalHistory> movements, pw.Font font, pw.Font fontBold) {
    return pw.TableHelper.fromTextArray(
      border: null,
      headerAlignment: pw.Alignment.centerLeft,
      cellAlignment: pw.Alignment.centerLeft,
      headerDecoration: const pw.BoxDecoration(
        color: primaryOrange,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      headerHeight: 30,
      cellHeight: 25,
      headerStyle: pw.TextStyle(color: PdfColors.white, font: fontBold, fontSize: 10),
      cellStyle: const pw.TextStyle(fontSize: 9),
      headers: ['Fecha', 'Categoría', 'Descripción', 'Importe'],
      data: movements.map((m) {
        return [
          m.currentDate,
          m.category.toUpperCase(),
          m.name,
          pw.Text(
            '${m.isIncome ? "+" : "-"}${m.money.toStringAsFixed(2)} €',
            style: pw.TextStyle(
              font: fontBold,
              color: m.isIncome ? incomeGreen : expenseRed,
            ),
          ),
        ];
      }).toList(),
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5)),
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context, pw.Font font) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Text(
        'Reporte generado automáticamente por AhorrApp - Página ${context.pageNumber} de ${context.pagesCount}',
        style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey),
      ),
    );
  }
}
