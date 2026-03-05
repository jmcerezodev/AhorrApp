import '../entities/shopping_template.dart';

abstract class IShoppingTemplateRepository {
  Future<List<ShoppingTemplate>> getTemplates(String userId);
  Future<void> saveTemplate(ShoppingTemplate template);
  Future<void> deleteTemplate(String id);
}
