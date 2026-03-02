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
  late int day; // Día del mes (1-31)
  late String category;
  late bool isActive;
  
  String? lastApplied; // Formato "MM-YYYY" para saber si ya se aplicó este mes

  late DateTime createdAt;
}
