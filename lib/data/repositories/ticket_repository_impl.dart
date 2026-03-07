import '../../domain/entities/ticket_item.dart';
import '../../domain/repositories/tickets_repository.dart';
import '../datasources/local/tickets_local_datasource.dart';
import '../local/models/local_ticket_item.dart';

class TicketsRepositoryImpl implements TicketsRepository {
  final TicketsLocalDataSource localDataSource;

  TicketsRepositoryImpl(this.localDataSource);

  @override
  Future<List<TicketItem>> getTicketItems(String userId) async {
    final models = await localDataSource.getTicketItems(userId);
    return models.map((m) => _toEntity(m)).toList();
  }

  @override
  Future<void> saveTicketItem(TicketItem item) async {
    await localDataSource.saveTicketItem(_fromEntity(item));
  }

  @override
  Future<void> deleteTicketItem(String id) async {
    await localDataSource.deleteTicketItem(id);
  }

  @override
  Future<void> clearTicketItems(String userId) async {
    await localDataSource.clearTicketItems(userId);
  }

  @override
  Future<void> reorderTicketItems(List<TicketItem> items) async {
    final models = items.asMap().entries.map((entry) {
      final item = entry.value;
      final model = _fromEntity(item);
      model.position = entry.key;
      return model;
    }).toList();
    await localDataSource.saveAll(models);
  }

  TicketItem _toEntity(LocalTicketItem model) {
    return TicketItem(
      id: model.ticketItemId,
      userId: model.userId,
      name: model.name,
      amount: model.amount,
      quantity: model.quantity,
      category: model.category,
      position: model.position,
    );
  }

  LocalTicketItem _fromEntity(TicketItem entity) {
    return LocalTicketItem()
      ..ticketItemId = entity.id
      ..userId = entity.userId
      ..name = entity.name
      ..amount = entity.amount
      ..quantity = entity.quantity
      ..category = entity.category
      ..position = entity.position;
  }
}
