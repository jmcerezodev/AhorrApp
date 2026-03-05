import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/data/local/models/local_shopping_item.dart';
import 'package:ahorrapp/domain/entities/shopping_item.dart';
import 'package:ahorrapp/domain/repositories/i_shopping_repository.dart';
import 'package:isar/isar.dart';

class IsarShoppingRepository implements IShoppingRepository {
  final LocalDbService _localDb = getIt<LocalDbService>();

  @override
  Future<List<ShoppingItem>> getShoppingList(String userId) async {
    final localItems = await _localDb.getShoppingList(userId);
    final sortedItems = [...localItems]..sort((a, b) => a.position.compareTo(b.position));
    return sortedItems.map((e) => _mapToEntity(e)).toList();
  }

  @override
  Future<void> saveShoppingItem(ShoppingItem item) async {
    final isar = _localDb.isar;
    final existingItem = await isar.localShoppingItems
        .filter()
        .appwriteIdEqualTo(item.id)
        .findFirst();

    final localItem = LocalShoppingItem()
      ..id = existingItem?.id ?? Isar.autoIncrement
      ..appwriteId = item.id
      ..userId = item.userId
      ..name = item.name
      ..amount = item.amount
      ..category = item.category
      ..isBought = item.isBought
      ..position = item.position
      ..createdAt = existingItem?.createdAt ?? DateTime.now();

    await _localDb.saveShoppingItems([localItem]);
  }

  @override
  Future<void> deleteShoppingItem(String id) async {
    await _localDb.deleteShoppingItemByAppwriteId(id);
  }

  @override
  Future<void> toggleItemBought(String id, bool isBought) async {
    final isar = _localDb.isar;
    final item = await isar.localShoppingItems.filter().appwriteIdEqualTo(id).findFirst();
    if (item != null) {
      item.isBought = isBought;
      await _localDb.saveShoppingItems([item]);
    }
  }

  @override
  Future<void> clearBoughtItems(String userId) async {
    final isar = _localDb.isar;
    await isar.writeTxn(() async {
      await isar.localShoppingItems
          .filter()
          .userIdEqualTo(userId)
          .isBoughtEqualTo(true)
          .deleteAll();
    });
  }

  ShoppingItem _mapToEntity(LocalShoppingItem local) {
    return ShoppingItem(
      id: local.appwriteId,
      userId: local.userId,
      name: local.name,
      amount: local.amount,
      category: local.category,
      isBought: local.isBought,
      position: local.position,
    );
  }
}
