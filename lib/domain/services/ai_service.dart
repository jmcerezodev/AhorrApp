import '../../domain/entities/ticket_item.dart';

abstract class AIService {
  Future<List<TicketItem>> parseTicketText(String rawText, String userId);

  /// Envía [rawText] ya extraído por OCR a la IA y devuelve el ticket parseado.
  /// Equivalente a [parseTicketText] pero con nombre explícito para el flujo
  /// de procesamiento diferido.
  Future<List<TicketItem>> processRawText(String rawText, String userId);
}
