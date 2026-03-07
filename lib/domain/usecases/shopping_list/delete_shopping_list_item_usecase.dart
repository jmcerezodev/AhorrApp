import 'package:ahorrapp/data/local/local_db_service.dart';
import '../../repositories/i_shopping_list_repository.dart';

class DeleteShoppingListItemUseCase {
  final IShoppingRepository localRepository;
  final IShoppingRepository remoteRepository;
  final LocalDbService localDbService;

  DeleteShoppingListItemUseCase({
    required this.localRepository,
    required this.remoteRepository,
    required this.localDbService,
  });

  Future<void> call(String id) async {
    // 1. Borrado local (Reactividad inmediata)
    await localRepository.deleteShoppingListItem(id);

    // 2. Sincronización remota
    try {
      await remoteRepository.deleteShoppingListItem(id);
    } catch (e) {
      // Si falla, encolamos para borrado diferido
      await localDbService.addPendingSync(
        'delete',
        'shopping_list',
        {},
        appwriteId: id,
      );
    }
  }
}
