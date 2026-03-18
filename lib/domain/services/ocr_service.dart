import 'dart:io';
import '../entities/ticket_item.dart';

abstract class OCRService {
  /// Ejecuta OCR local y devuelve el texto crudo. Lanza [Exception] si no
  /// detecta texto. No realiza ninguna llamada de red.
  Future<String> extractText(File imageFile);

  /// OCR + llamada a la IA en un solo paso (para compatibilidad).
  Future<List<TicketItem>> processTicket(File imageFile, String userId);
}
