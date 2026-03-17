import '../entities/ticket_item.dart';

abstract class TicketsRepository {
  Future<List<TicketItem>> getTicketItems(String userId);
  Future<TicketItem?> getTicketItemById(String id);
  Future<void> saveTicketItem(TicketItem item);
  Future<void> deleteTicketItem(String id);
  Future<void> clearTicketItems(String userId);
  Future<void> reorderTicketItems(List<TicketItem> items);
  Future<void> unmarkAsTransferred(String ticketId);

  /// Descarga desde Appwrite Storage las imágenes de los tickets que tienen
  /// [remoteImageId] pero no tienen archivo local válido.
  /// Usado para recuperar imágenes tras reinstalación de la app.
  Future<void> downloadMissingImages(String userId);
}
