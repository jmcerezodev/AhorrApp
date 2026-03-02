import 'package:isar/isar.dart';

part 'local_recurrent_expense.g.dart';

@collection
class LocalRecurrentExpense {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String appwriteId;

  late String userId;
  late String name;
  late double money;
  int? day; // Ahora es opcional (int?)
  late String category;
  late bool isActive;
  
  String? lastApplied;

  late DateTime createdAt;
}
