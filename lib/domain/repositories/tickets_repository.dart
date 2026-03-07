import '../entities/ticket_item.dart';

abstract class TicketsRepository {
  Future<List<TicketItem>> getTicketItems(String userId);
  Future<void> saveTicketItem(TicketItem item);
  Future<void> deleteTicketItem(String id);
  Future<void> clearTicketItems(String userId);
  Future<void> reorderTicketItems(List<TicketItem> items);
}
