import 'package:ahorrapp/data/local/local_db_service.dart';
import '../../entities/shopping_list_item.dart';
import '../../repositories/i_shopping_list_repository.dart';

class SaveShoppingListItemUseCase {
  final IShoppingRepository localRepository;
  final IShoppingRepository remoteRepository;
  final LocalDbService localDbService;

  SaveShoppingListItemUseCase({
    required this.localRepository,
    required this.remoteRepository,
    required this.localDbService,
  });

  Future<void> call(ShoppingListItem item) async {
    // 1. Guardado local (Siempre primero para reactividad inmediata)
    await localRepository.saveShoppingItem(item);

    // 2. Sincronización remota
    try {
      await remoteRepository.saveShoppingItem(item);
    } catch (e) {
      // Si falla la red, guardamos en la cola de pendientes
      // Nota: Usamos 'create' como acción genérica para guardar/actualizar en Appwrite
      await localDbService.addPendingSync(
        'save', 
        'shopping_list',
        {
          'userId': item.userId,
          'name': item.name,
          'amount': item.amount,
          'category': item.category,
          'isBought': item.isBought,
          'position': item.position,
          'quantity': item.quantity,
        },
        appwriteId: item.id,
      );
    }
  }
}
