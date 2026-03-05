import '../../entities/shopping_template.dart';
import '../../repositories/i_shopping_template_repository.dart';

class GetShoppingTemplatesUseCase {
  final IShoppingTemplateRepository repository;

  GetShoppingTemplatesUseCase({required this.repository});

  Future<List<ShoppingTemplate>> call(String userId) async {
    return await repository.getTemplates(userId);
  }
}
