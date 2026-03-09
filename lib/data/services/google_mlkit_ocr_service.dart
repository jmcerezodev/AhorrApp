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
      File optimizedImage = await _optimizeImageInBackground(imageFile.path);
      
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

  Future<File> _optimizeImageInBackground(String imagePath) async {
    try {
      final optimizedBytes = await compute(_imageProcessingTask, imagePath);
      
      if (optimizedBytes == null) return File(imagePath);

      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/opt_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File optimizedFile = File(tempPath);
      await optimizedFile.writeAsBytes(optimizedBytes);
      
      return optimizedFile;
    } catch (e) {
      debugPrint('⚠️ Error en optimización en background: $e');
      return File(imagePath);
    }
  }

  static Uint8List? _imageProcessingTask(String path) {
    try {
      final bytes = File(path).readAsBytesSync();
      img.Image? image = img.decodeImage(bytes);
      if (image == null) return null;

      image = img.bakeOrientation(image);
      image = img.grayscale(image);
      image = img.contrast(image, contrast: 1.25);
      image = img.adjustColor(image, brightness: 1.05);

      return Uint8List.fromList(img.encodeJpg(image, quality: 90));
    } catch (e) {
      return null;
    }
  }

  @visibleForTesting
  String extractOptimizedText(RecognizedText recognizedText) {
    final List<TextLine> allLines = [];
    for (TextBlock block in recognizedText.blocks) {
      allLines.addAll(block.lines);
    }

    if (allLines.isEmpty) return "";

    // 1. Ordenar de arriba hacia abajo
    allLines.sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));

    // 2. Agrupar líneas que están en la misma fila horizontal (umbral de 25px)
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
    final noiseRegex = RegExp(r'(tel|http|www|dir|fax|cod|iva|mesa|camarero|vuelva|visita|gracias)', caseSensitive: false);

    for (var row in rows) {
      // Ordenar elementos de la fila de izquierda a derecha
      row.sort((a, b) => a.boundingBox.left.compareTo(b.boundingBox.left));
      
      // Unir textos de la fila con el separador de columna |
      String rowText = row.map((l) => l.text.trim()).join(" | ");
      rowText = rowText.replaceAll(RegExp(r'\s+'), ' ').trim();
      
      if (rowText.length < 2) continue;
      if (noiseRegex.hasMatch(rowText)) continue;
      if (RegExp(r'^[ \.\-\*_:=|]+$').hasMatch(rowText)) continue;
      
      optimizedLines.add(rowText);
    }

    return optimizedLines.join('\n');
  }

  void dispose() {
    _textRecognizer.close();
  }
}
