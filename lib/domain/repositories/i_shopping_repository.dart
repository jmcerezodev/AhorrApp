import '../entities/shopping_item.dart';

abstract class IShoppingRepository {
  Future<List<ShoppingItem>> getShoppingList(String userId);
  Future<void> saveShoppingItem(ShoppingItem item);
  Future<void> deleteShoppingItem(String id);
  Future<void> toggleItemBought(String id, bool isBought);
  Future<void> clearBoughtItems(String userId);
}
