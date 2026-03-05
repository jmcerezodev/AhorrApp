import 'package:ahorrapp/data/local/local_db_service.dart';
import '../../repositories/i_shopping_repository.dart';

class DeleteShoppingItemUseCase {
  final IShoppingRepository localRepository;
  final IShoppingRepository remoteRepository;
  final LocalDbService localDbService;

  DeleteShoppingItemUseCase({
    required this.localRepository,
    required this.remoteRepository,
    required this.localDbService,
  });

  Future<void> call(String id) async {
    // 1. Borrado local
    await localRepository.deleteShoppingItem(id);

    // 2. Sincronización remota
    try {
      await remoteRepository.deleteShoppingItem(id);
    } catch (e) {
      await localDbService.addPendingSync(
        'delete',
        'shopping',
        {},
        appwriteId: id,
      );
    }
  }
}
