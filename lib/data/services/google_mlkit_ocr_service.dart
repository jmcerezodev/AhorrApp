import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/ticket_item.dart';
import '../../domain/services/ocr_service.dart';

class GoogleMlKitOCRService implements OCRService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<List<TicketItem>> processTicket(File imageFile, String userId) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      // 1. Aplanamos y ordenamos todas las líneas por su posición vertical (Y)
      final List<TextLine> allLines = [];
      for (TextBlock block in recognizedText.blocks) {
        allLines.addAll(block.lines);
      }
      allLines.sort((a, b) => a.boundingBox.top.compareTo(b.boundingBox.top));

      List<TicketItem> items = [];
      
      // Variables de estado para el análisis multi-línea
      String? pendingName;
      int pendingQuantity = 1;
      
      final List<String> stopKeywords = [
        'total', 'subtotal', 'iva', 'cif', 'pago', 'efectivo', 'tarjeta', 'puntos'
      ];

      for (TextLine line in allLines) {
        String text = line.text.trim();
        if (text.length < 2) continue;

        // Detectar palabras de parada para resetear el estado y evitar falsos positivos del pie del ticket
        final lowerText = text.toLowerCase();
        if (stopKeywords.any((kw) => lowerText.contains(kw))) {
          pendingName = null;
          pendingQuantity = 1;
          continue;
        }

        // Regex para buscar un precio (ej: 1.50, 1,50€, 1.50A)
        final RegExp priceRegExp = RegExp(r'(\d+[\.,]\d{2})(?:\s*[A-Za-z€%])?');
        final match = priceRegExp.firstMatch(text);

        if (match != null) {
          // --- CASO A: HAY UN PRECIO EN ESTA LÍNEA ---
          final String priceStr = match.group(1)!.replaceAll(',', '.');
          final double? price = double.tryParse(priceStr);
          
          if (price != null && price > 0) {
            // Intentamos sacar el nombre de esta misma línea
            String nameInLine = text.substring(0, match.start).trim();
            nameInLine = _cleanName(nameInLine);

            // Si no hay nombre en esta línea, usamos el que tengamos guardado de arriba
            final String finalName = nameInLine.length > 2 ? nameInLine : (pendingName ?? '');
            
            if (finalName.length > 2) {
              items.add(TicketItem(
                id: const Uuid().v4(),
                userId: userId,
                name: _capitalize(finalName),
                amount: price,
                quantity: pendingQuantity,
                category: _inferCategory(finalName),
              ));
            }
            
            // Limpiamos estado tras encontrar un precio
            pendingName = null;
            pendingQuantity = 1;
          }
        } else {
          // --- CASO B: NO HAY PRECIO, ES POSIBLE NOMBRE O CANTIDAD ---
          
          // 1. Verificamos si empieza por una cantidad (ej: "2 x", "1  ")
          final RegExp qtyRegExp = RegExp(r'^(\d+)\s*[xX\*]?\s+');
          final qtyMatch = qtyRegExp.firstMatch(text);
          
          if (qtyMatch != null) {
            pendingQuantity = int.tryParse(qtyMatch.group(1) ?? '1') ?? 1;
            // El resto de la línea es el nombre
            String potentialName = text.substring(qtyMatch.end).trim();
            if (potentialName.length > 2) {
              pendingName = _cleanName(potentialName);
            }
          } else {
            // Es una línea de texto puro, la guardamos como nombre pendiente
            final cleaned = _cleanName(text);
            if (cleaned.length > 2) {
              pendingName = cleaned;
            }
          }
        }
      }

      return items;
    } catch (e) {
      throw Exception("Error en procesamiento OCR: $e");
    }
  }

  String _cleanName(String name) {
    // Quitamos ruido común de tickets
    return name.replaceAll(RegExp(r'[\.\-\*_:=]'), ' ').trim();
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    final String clean = text.toLowerCase();
    return clean[0].toUpperCase() + clean.substring(1);
  }

  String _inferCategory(String name) {
    final n = name.toLowerCase();
    if (RegExp(r'(leche|pan|huevo|fruta|yogur|queso|carne|pollo|agua|pasta|arroz|aceite|vino|cerveza|refresco|comida|ali)').hasMatch(n)) return 'alimentación';
    if (RegExp(r'(limpieza|detergente|lavavajillas|papel|suavizante|lejia|bolsa|servilleta|hogar)').hasMatch(n)) return 'hogar';
    if (RegExp(r'(gasolina|repostar|parking|peaje|autobus|metro|transporte)').hasMatch(n)) return 'transporte';
    if (RegExp(r'(cine|restaurante|caña|copa|concierto|ocio|hamburguesa|pizza|bar|cafeteria)').hasMatch(n)) return 'ocio';
    if (RegExp(r'(farmacia|medicina|gel|champu|crema|higiene|paracetamol|salud)').hasMatch(n)) return 'salud';
    return 'general';
  }

  void dispose() {
    _textRecognizer.close();
  }
}
