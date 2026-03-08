import 'package:isar/isar.dart';
import '../../local/models/local_ticket_item.dart';

class TicketsLocalDataSource {
  final Isar isar;
  TicketsLocalDataSource(this.isar);

  Future<List<LocalTicketItem>> getTicketItems(String userId) async {
    return await isar.localTicketItems.filter().userIdEqualTo(userId).sortByPosition().findAll();
  }

  Future<LocalTicketItem?> getTicketItemById(String ticketItemId) async {
    return await isar.localTicketItems.filter().ticketItemIdEqualTo(ticketItemId).findFirst();
  }

  Future<void> saveTicketItem(LocalTicketItem item) async {
    await isar.writeTxn(() async {
      final existing = await isar.localTicketItems.filter().ticketItemIdEqualTo(item.ticketItemId).findFirst();
      
      if (existing != null) {
        item.id = existing.id;
      }
      
      await isar.localTicketItems.put(item);
    });
  }

  Future<void> deleteTicketItem(String ticketItemId) async {
    await isar.writeTxn(() async {
      await isar.localTicketItems.filter().ticketItemIdEqualTo(ticketItemId).deleteAll();
    });
  }

  Future<void> clearTicketItems(String userId) async {
    await isar.writeTxn(() async {
      await isar.localTicketItems.filter().userIdEqualTo(userId).deleteAll();
    });
  }

  Future<void> saveAll(List<LocalTicketItem> items) async {
    await isar.writeTxn(() async {
      for (var item in items) {
        final existing = await isar.localTicketItems.filter().ticketItemIdEqualTo(item.ticketItemId).findFirst();
        if (existing != null) {
          item.id = existing.id;
        }
      }
      await isar.localTicketItems.putAll(items);
    });
  }

  Future<void> updateTransferredStatus(String ticketItemId, bool isTransferred) async {
    await isar.writeTxn(() async {
      final existing = await isar.localTicketItems.filter().ticketItemIdEqualTo(ticketItemId).findFirst();
      if (existing != null) {
        existing.isTransferred = isTransferred;
        await isar.localTicketItems.put(existing);
      }
    });
  }
}
