import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../domain/entities/ticket_item.dart';
import '../../domain/services/ocr_service.dart';
import '../../domain/services/ai_service.dart';

class GoogleMlKitOCRService implements OCRService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final AIService aiService;

  GoogleMlKitOCRService(this.aiService);

  @override
  Future<List<TicketItem>> processTicket(File imageFile, String userId) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      final String optimizedText = _extractOptimizedText(recognizedText);

      if (optimizedText.isEmpty) return [];

      return await aiService.parseTicketText(optimizedText, userId);
    } catch (e) {
      throw Exception("Error en procesamiento OCR + AI: $e");
    }
  }

  String _extractOptimizedText(RecognizedText recognizedText) {
    final List<TextLine> allLines = [];
    for (TextBlock block in recognizedText.blocks) {
      allLines.addAll(block.lines);
    }

    if (allLines.isEmpty) return "";

    allLines.sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));

    final List<List<TextLine>> rows = [];
    if (allLines.isNotEmpty) {
      List<TextLine> currentRow = [allLines[0]];
      for (int i = 1; i < allLines.length; i++) {
        final line = allLines[i];
        final prevLine = allLines[i - 1];
        
        if ((line.boundingBox.top - prevLine.boundingBox.top).abs() < 12) {
          currentRow.add(line);
        } else {
          rows.add(currentRow);
          currentRow = [line];
        }
      }
      rows.add(currentRow);
    }

    final List<String> optimizedLines = [];
    final List<String> noiseKeywords = [
      'cif', 'iva', 'subtotal', 'efectivo', 'tarjeta', 'cambio',
      'atendido', 'fecha', 'hora', 'tel', 'dirección', 'cliente',
      'puntos', 'ahorro', 'promoción', 'factura', 'gracias',
    ];

    for (var row in rows) {
      row.sort((a, b) => a.boundingBox.left.compareTo(b.boundingBox.left));
      
      // Usamos '|' como delimitador para dar estructura de columnas a la IA
      String rowText = row.map((l) => l.text).join(" | ").trim();
      String lowerRowText = rowText.toLowerCase();

      if (noiseKeywords.any((kw) => lowerRowText.contains(kw))) continue;
      if (RegExp(r'\d{7,}').hasMatch(rowText)) continue;
      if (RegExp(r'^[ \.\-\*_:=|]+$').hasMatch(rowText)) continue;
      if (rowText.length < 2) continue;
      
      optimizedLines.add(rowText);
    }

    return optimizedLines.join('\n');
  }

  void dispose() {
    _textRecognizer.close();
  }
}
