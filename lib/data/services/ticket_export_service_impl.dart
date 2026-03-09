import 'dart:io';
import 'package:ahorrapp/domain/services/ticket_export_service.dart';
import 'package:gal/gal.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class TicketExportServiceImpl implements TicketExportService {
  
  @override
  Future<String?> saveImageToGallery(File imageFile) async {
    try {
      await Gal.putImage(imageFile.path);
      return 'Galería de fotos';
    } catch (e) {
      throw Exception('Error al guardar en la galería: $e');
    }
  }

  @override
  Future<void> savePdfWithSystem(File imageFile, String fileName) async {
    try {
      final image = pw.MemoryImage(imageFile.readAsBytesSync());

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async {
          final doc = pw.Document();
          
          doc.addPage(
            pw.Page(
              pageFormat: format,
              build: (pw.Context context) {
                // Forzamos el ancho a 80mm (tamaño real aproximado de un ticket)
                final double ticketWidth = 80 * PdfPageFormat.mm;

                return pw.Center(
                  child: pw.Image(
                    image,
                    width: ticketWidth,
                  ),
                );
              },
            ),
          );
          return doc.save();
        },
        name: fileName,
      );
    } catch (e) {
      throw Exception('Error al procesar PDF: $e');
    }
  }

  @override
  Future<void> shareTicketImage(File imageFile, String text) async {
    try {
      await Share.shareXFiles([XFile(imageFile.path)], text: text);
    } catch (e) {
      throw Exception('Error al compartir imagen: $e');
    }
  }
}
