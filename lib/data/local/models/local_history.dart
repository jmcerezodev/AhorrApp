import 'package:isar/isar.dart';

part 'local_history.g.dart';

@collection
class LocalHistory {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String appwriteId;

  late String name;
  late double money;
  late bool isIncome;
  late String type; // 'income', 'expense', 'saving'
  late String currentDate;
  late String currentHour;
  late String month;
  late int year;
  late DateTime createdAt;

  bool isSpent = false; // NUEVO: Indica si este ahorro ya se ha "vaciado" o gastado
}
