import 'package:isar/isar.dart';

part 'local_shopping_list_item.g.dart';

@collection
class LocalShoppingItem {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String appwriteId;

  late String userId;
  late String name;
  late double amount;
  late String category;
  late bool isBought;
  late int position;
  late DateTime createdAt;
}
