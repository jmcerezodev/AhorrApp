import '../../entities/shopping_list_item.dart';
import '../../repositories/i_shopping_list_repository.dart';

class GetShoppingListUseCase {
  final IShoppingRepository localRepository;

  GetShoppingListUseCase({required this.localRepository});

  Future<List<ShoppingListItem>> call(String userId) async {
    return await localRepository.getShoppingList(userId);
  }
}
