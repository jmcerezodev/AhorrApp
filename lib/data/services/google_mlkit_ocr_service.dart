import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
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
      File optimizedImage = await _optimizeImage(imageFile);
      
      InputImage inputImage = InputImage.fromFile(optimizedImage);
      RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      String optimizedText = extractOptimizedText(recognizedText);
      
      if (optimizedText.isEmpty && optimizedImage.path != imageFile.path) {
        inputImage = InputImage.fromFile(imageFile);
        recognizedText = await _textRecognizer.processImage(inputImage);
        optimizedText = extractOptimizedText(recognizedText);
      }

      if (optimizedImage.path != imageFile.path) {
        await optimizedImage.delete().catchError((_) => optimizedImage);
      }

      if (optimizedText.isEmpty) return [];

      return await aiService.parseTicketText(optimizedText, userId);
    } catch (e) {
      throw Exception("Error en procesamiento OCR + AI: $e");
    }
  }

  Future<File> _optimizeImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      if (image == null) return imageFile;

      image = img.bakeOrientation(image);
      image = img.grayscale(image);
      image = img.contrast(image, contrast: 1.2);
      image = img.adjustColor(image, brightness: 1.02);

      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/opt_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File optimizedFile = File(tempPath);
      await optimizedFile.writeAsBytes(img.encodeJpg(image, quality: 95));
      
      return optimizedFile;
    } catch (e) {
      return imageFile;
    }
  }

  @visibleForTesting
  String extractOptimizedText(RecognizedText recognizedText) {
    final List<TextLine> allLines = [];
    for (TextBlock block in recognizedText.blocks) {
      allLines.addAll(block.lines);
    }

    if (allLines.isEmpty) return "";

    // Ordenar de arriba hacia abajo para mantener la estructura del ticket
    allLines.sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));

    final List<List<TextLine>> rows = [];
    if (allLines.isNotEmpty) {
      List<TextLine> currentRow = [allLines[0]];
      for (int i = 1; i < allLines.length; i++) {
        final line = allLines[i];
        final prevLine = allLines[i - 1];
        if ((line.boundingBox.top - prevLine.boundingBox.top).abs() < 25) {
          currentRow.add(line);
        } else {
          rows.add(currentRow);
          currentRow = [line];
        }
      }
      rows.add(currentRow);
    }

    final List<String> optimizedLines = [];
    final noiseKeywords = {
      'cif', 'subtotal', 'efectivo', 'tarjeta', 'pago', 
      'tel', 'direccion', 'cliente', 'articulos', 'puntos', 
      'promocion', 'factura', 'gracias', 'atendido', 'vendedor'
    };
    
    for (var row in rows) {
      row.sort((a, b) => a.boundingBox.left.compareTo(b.boundingBox.left));
      
      String rowText = row.map((l) => l.text.trim()).join(" | ");
      rowText = rowText.replaceAll(RegExp(r'\s+'), ' ').trim();
      
      final lowerText = rowText.toLowerCase();

      // Saltamos ruido conocido pero NO saltamos si no hay números, 
      // para capturar el nombre del establecimiento al principio.
      if (noiseKeywords.any((kw) => lowerText.contains(kw))) continue;
      
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
