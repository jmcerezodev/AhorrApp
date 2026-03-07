import '../../domain/entities/ticket_item.dart';

abstract class AIService {
  Future<List<TicketItem>> parseTicketText(String rawText, String userId);
}
