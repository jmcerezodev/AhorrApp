import 'dart:convert';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/data/local/models/local_shopping_template.dart';
import 'package:ahorrapp/domain/entities/shopping_template.dart';
import 'package:ahorrapp/domain/repositories/i_shopping_template_repository.dart';

class IsarShoppingTemplateRepository implements IShoppingTemplateRepository {
  final LocalDbService _localDb = LocalDbService();

  @override
  Future<List<ShoppingTemplate>> getTemplates(String userId) async {
    final locals = await _localDb.getShoppingTemplates(userId);
    return locals.map((l) => _mapToEntity(l)).toList();
  }

  @override
  Future<void> saveTemplate(ShoppingTemplate template) async {
    final local = LocalShoppingTemplate()
      ..appwriteId = template.id
      ..userId = template.userId
      ..name = template.name
      ..itemsJson = jsonEncode(template.items.map((i) => i.toJson()).toList())
      ..createdAt = DateTime.now();
    
    await _localDb.saveShoppingTemplates([local]);
  }

  @override
  Future<void> deleteTemplate(String id) async {
    await _localDb.deleteShoppingTemplateByAppwriteId(id);
  }

  ShoppingTemplate _mapToEntity(LocalShoppingTemplate local) {
    final List<dynamic> decoded = jsonDecode(local.itemsJson);
    final items = decoded.map((i) => ShoppingTemplateItem.fromJson(i)).toList();
    
    return ShoppingTemplate(
      id: local.appwriteId,
      userId: local.userId,
      name: local.name,
      items: items,
    );
  }
}
