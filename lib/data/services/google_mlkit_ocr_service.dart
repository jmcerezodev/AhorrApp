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
  Future<String> extractText(File imageFile) async {
    // 1. Optimización en Isolate
    File optimizedImage = await _optimizeImageInBackground(imageFile.path);

    // 2. OCR — ML Kit corre en su propio hilo nativo
    InputImage inputImage = InputImage.fromFile(optimizedImage);
    RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
    String optimizedText = extractOptimizedText(recognizedText);

    // Reintento con imagen original si la optimizada no dio texto
    if (optimizedText.isEmpty && optimizedImage.path != imageFile.path) {
      inputImage = InputImage.fromFile(imageFile);
      recognizedText = await _textRecognizer.processImage(inputImage);
      optimizedText = extractOptimizedText(recognizedText);
    }

    // Limpieza de temporales
    if (optimizedImage.path != imageFile.path) {
      await optimizedImage.delete().catchError((_) => optimizedImage);
    }

    if (optimizedText.isEmpty) {
      throw Exception(
        'No se detectó texto en la imagen. '
        'Asegúrate de que el ticket esté bien iluminado y enfocado.',
      );
    }

    return optimizedText;
  }

  @override
  Future<List<TicketItem>> processTicket(File imageFile, String userId) async {
    final text = await extractText(imageFile);
    return aiService.parseTicketText(text, userId);
  }

  Future<File> _optimizeImageInBackground(String imagePath) async {
    try {
      // Usamos compute para ejecutar el procesamiento pesado en un Isolate secundario pasando el path
      final optimizedBytes = await compute(_imageProcessingTask, imagePath);
      
      if (optimizedBytes == null) return File(imagePath);

      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/opt_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File optimizedFile = File(tempPath);
      await optimizedFile.writeAsBytes(optimizedBytes);
      
      return optimizedFile;
    } catch (_) {
      return File(imagePath);
    }
  }

  static Uint8List? _imageProcessingTask(String path) {
    try {
      final bytes = File(path).readAsBytesSync();
      img.Image? image = img.decodeImage(bytes);
      if (image == null) return null;

      // Aplicar filtros quirúrgicos para OCR
      image = img.bakeOrientation(image);
      image = img.grayscale(image);
      image = img.contrast(image, contrast: 1.25);
      image = img.adjustColor(image, brightness: 1.05);

      // ALTA CALIDAD PARA OCR: Redimensionamos a 1200px y calidad 85% para máxima precisión
      if (image.width > 1200) {
        image = img.copyResize(image, width: 1200, interpolation: img.Interpolation.linear);
      }

      return Uint8List.fromList(img.encodeJpg(image, quality: 85));
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

    // Ordenar de arriba hacia abajo
    allLines.sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));

    final List<String> optimizedLines = [];
    
    // Filtro de ruido menos agresivo para no perder información vital
    final noiseRegex = RegExp(r'(tel|http|www|dir|fax|cod|iva|mesa|camarero|vuelva|visita|gracias)', caseSensitive: false);

    for (var row in _groupLinesByRow(allLines)) {
      // Ordenar elementos de la fila de izquierda a derecha
      row.sort((a, b) => a.boundingBox.left.compareTo(b.boundingBox.left));
      
      // Unir textos de la fila con el separador de columna |
      String rowText = row.map((l) => l.text.trim()).join(" | ");
      rowText = rowText.replaceAll(RegExp(r'\s+'), ' ').trim();
      
      if (rowText.length < 2) continue;
      // Líneas largas (>30 chars) casi siempre son textos legales, publicidad
      // o direcciones que no aportan ni nombre de comercio ni total.
      if (rowText.length > 30) continue;
      if (noiseRegex.hasMatch(rowText)) continue;
      if (RegExp(r'^[ \.\-\*_:=|]+$').hasMatch(rowText)) continue;
      
      optimizedLines.add(rowText);
    }

    return optimizedLines.join('\n');
  }

  List<List<TextLine>> _groupLinesByRow(List<TextLine> allLines) {
    final List<List<TextLine>> rows = [];
    if (allLines.isEmpty) return rows;

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
    return rows;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
