import 'dart:io';
import 'package:ahorrapp/domain/services/ticket_export_service.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class TicketExportServiceImpl implements TicketExportService {

  @override
  Future<String?> saveImageToGallery(File imageFile) async {
    await Gal.putImage(imageFile.path);
    return 'Galería de fotos';
  }

  @override
  Future<void> savePdfWithSystem(File imageFile, String fileName) async {
    final image = pw.MemoryImage(imageFile.readAsBytesSync());
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(image, fit: pw.BoxFit.contain),
          );
        },
      ),
    );

    final bytes = await doc.save();
    final dir = await getTemporaryDirectory();
    // Nombre de archivo seguro: reemplaza espacios y caracteres problemáticos
    final safeName = fileName.replaceAll(RegExp(r'[^\w\-]'), '_');
    final pdfFile = File('${dir.path}/$safeName.pdf');
    await pdfFile.writeAsBytes(bytes);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(pdfFile.path, mimeType: 'application/pdf')],
        subject: fileName,
      ),
    );
  }

  @override
  Future<void> shareTicketImage(File imageFile, String text) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(imageFile.path)], text: text),
    );
  }
}
