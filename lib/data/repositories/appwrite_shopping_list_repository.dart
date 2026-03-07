import 'package:ahorrapp/domain/entities/shopping_list_item.dart';
import 'package:ahorrapp/domain/repositories/i_shopping_list_repository.dart';
import '../appwrite/appwrite_repository.dart';

class AppwriteShoppingListRepository implements IShoppingRepository {
  final AppwriteRepository _dataSource = AppwriteRepository();

  @override
  Future<List<ShoppingListItem>> getShoppingList(String userId) async {
    final docs = await _dataSource.getShoppingList(userId);
    return docs.map((doc) => ShoppingListItem(
      id: doc.$id,
      userId: doc.data['userId'] ?? '',
      name: doc.data['name'] ?? '',
      amount: (doc.data['amount'] as num?)?.toDouble() ?? 0.0,
      category: doc.data['category'] ?? 'general',
      isBought: doc.data['isBought'] ?? false,
      position: doc.data['position'] ?? 0,
      quantity: doc.data['quantity'] ?? 1,
    )).toList();
  }

  @override
  Future<void> saveShoppingItem(ShoppingListItem item) async {
    try {
      // Intentamos actualizar primero
      await _dataSource.updateShoppingItem(
        documentId: item.id, 
        data: {
          'name': item.name,
          'amount': item.amount,
          'category': item.category,
          'isBought': item.isBought,
          'position': item.position,
          'quantity': item.quantity,
        }
      );
    } catch (e) {
      // Si no existe (404), lo creamos
      await _dataSource.addShoppingItem(
        documentId: item.id,
        userId: item.userId,
        name: item.name,
        amount: item.amount,
        category: item.category,
        isBought: item.isBought,
        position: item.position,
        quantity: item.quantity,
      );
    }
  }

  @override
  Future<void> deleteShoppingListItem(String id) async {
    await _dataSource.deleteShoppingItem(id);
  }

  @override
  Future<void> toggleItemBought(String id, bool isBought) async {
    await _dataSource.updateShoppingItem(
      documentId: id, 
      data: {'isBought': isBought}
    );
  }

  @override
  Future<void> clearBoughtItems(String userId) async {
    // La limpieza masiva se suele gestionar item por item en el caso de uso 
    // para mantener la sincronización local/remota controlada.
  }
}
