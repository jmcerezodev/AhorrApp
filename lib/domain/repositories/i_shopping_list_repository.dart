import '../entities/shopping_list_item.dart';

abstract class IShoppingRepository {
  Future<List<ShoppingListItem>> getShoppingList(String userId);
  Future<void> saveShoppingItem(ShoppingListItem item);
  Future<void> deleteShoppingListItem(String id);
  Future<void> toggleItemBought(String id, bool isBought);
  Future<void> clearBoughtItems(String userId);
}
