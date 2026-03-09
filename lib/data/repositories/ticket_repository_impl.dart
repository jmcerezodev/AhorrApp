import 'dart:io';
import '../../core/di/service_locator.dart';
import '../../core/sync/sync_service.dart';
import '../../domain/entities/ticket_item.dart';
import '../../domain/repositories/tickets_repository.dart';
import '../datasources/local/tickets_local_datasource.dart';
import '../local/local_db_service.dart';
import '../local/models/local_ticket_item.dart';

class TicketsRepositoryImpl implements TicketsRepository {
  final TicketsLocalDataSource localDataSource;
  final LocalDbService _localDb = getIt<LocalDbService>();
  final SyncService _syncService = getIt<SyncService>();

  TicketsRepositoryImpl(this.localDataSource);

  @override
  Future<List<TicketItem>> getTicketItems(String userId) async {
    final models = await localDataSource.getTicketItems(userId);
    return models.map((m) => _toEntity(m)).toList();
  }

  @override
  Future<TicketItem?> getTicketItemById(String id) async {
    final model = await localDataSource.getTicketItemById(id);
    return model != null ? _toEntity(model) : null;
  }

  @override
  Future<void> saveTicketItem(TicketItem item) async {
    await localDataSource.saveTicketItem(_fromEntity(item));
    
    await _localDb.addPendingSync(
      'save', 
      'tickets', 
      {
        'ticketItemId': item.id,
        'userId': item.userId,
        'name': item.name,
        'amount': item.amount,
        'date': item.date.toIso8601String(),
        'category': item.category,
        'position': item.position,
        'isTransferred': item.isTransferred,
        'remoteImageId': item.remoteImageId,
        'imagePath': item.imagePath, 
      },
      appwriteId: item.id,
    );
    _syncService.processQueue();
  }

  @override
  Future<void> deleteTicketItem(String id) async {
    final localItem = await localDataSource.getTicketItemById(id);
    
    if (localItem?.imagePath != null) {
      try {
        final file = File(localItem!.imagePath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
    }

    await localDataSource.deleteTicketItem(id);
    
    await _localDb.addPendingSync(
      'delete', 
      'tickets', 
      {'remoteImageId': localItem?.remoteImageId}, 
      appwriteId: id
    );
    _syncService.processQueue();
  }

  @override
  Future<void> clearTicketItems(String userId) async {
    final items = await localDataSource.getTicketItems(userId);
    for (var item in items) {
      if (item.imagePath != null) {
        try {
          final file = File(item.imagePath!);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (_) {}
      }
      await _localDb.addPendingSync(
        'delete', 
        'tickets', 
        {'remoteImageId': item.remoteImageId}, 
        appwriteId: item.ticketItemId
      );
    }
    await localDataSource.clearTicketItems(userId);
    _syncService.processQueue();
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
    
    for (var item in items) {
      await _localDb.addPendingSync(
        'save', 
        'tickets', 
        {
          'ticketItemId': item.id,
          'userId': item.userId,
          'name': item.name,
          'amount': item.amount,
          'date': item.date.toIso8601String(),
          'category': item.category,
          'position': items.indexOf(item),
          'isTransferred': item.isTransferred,
          'remoteImageId': item.remoteImageId,
          'imagePath': item.imagePath,
        },
        appwriteId: item.id,
      );
    }
    _syncService.processQueue();
  }

  @override
  Future<void> unmarkAsTransferred(String ticketId) async {
    await localDataSource.updateTransferredStatus(ticketId, false);
    
    final item = await localDataSource.getTicketItemById(ticketId);
    if (item != null) {
      await _localDb.addPendingSync(
        'save', 
        'tickets', 
        {
          'isTransferred': false,
          'imagePath': item.imagePath, 
          'remoteImageId': item.remoteImageId,
          'ticketItemId': item.ticketItemId,
          'userId': item.userId,
          'name': item.name,
          'amount': item.amount,
          'date': item.date.toIso8601String(),
          'category': item.category,
          'position': item.position,
        },
        appwriteId: ticketId,
      );
      _syncService.processQueue();
    }
  }

  TicketItem _toEntity(LocalTicketItem model) {
    return TicketItem(
      id: model.ticketItemId,
      userId: model.userId,
      name: model.name,
      amount: model.amount,
      date: model.date,
      imagePath: model.imagePath,
      remoteImageId: model.remoteImageId,
      category: model.category,
      position: model.position,
      isTransferred: model.isTransferred,
    );
  }

  LocalTicketItem _fromEntity(TicketItem entity) {
    return LocalTicketItem()
      ..ticketItemId = entity.id
      ..userId = entity.userId
      ..name = entity.name
      ..amount = entity.amount
      ..date = entity.date
      ..imagePath = entity.imagePath
      ..remoteImageId = entity.remoteImageId
      ..category = entity.category
      ..position = entity.position
      ..isTransferred = entity.isTransferred;
  }
}
