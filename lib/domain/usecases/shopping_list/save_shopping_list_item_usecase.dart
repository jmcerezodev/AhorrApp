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
    // 1. Guardado local
    await localRepository.saveShoppingItem(item);

    // 2. Sincronización remota
    try {
      await remoteRepository.saveShoppingItem(item);
    } catch (e) {
      await localDbService.addPendingSync(
        'create',
        'recurrent_expenses', // Usaremos una colección genérica o específica
        {
          'userId': item.userId,
          'name': item.name,
          'amount': item.amount,
          'category': item.category,
          'isBought': item.isBought,
          'position': item.position,
        },
        appwriteId: item.id,
      );
    }
  }
}
