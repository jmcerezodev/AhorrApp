import '../../entities/shopping_item.dart';
import '../../repositories/i_shopping_repository.dart';

class GetShoppingListUseCase {
  final IShoppingRepository localRepository;

  GetShoppingListUseCase({required this.localRepository});

  Future<List<ShoppingItem>> call(String userId) async {
    return await localRepository.getShoppingList(userId);
  }
}
