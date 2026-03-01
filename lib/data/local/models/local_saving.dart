import 'package:isar/isar.dart';

part 'local_saving.g.dart';

@collection
class LocalSaving {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String appwriteId;

  late String userId;
  late double money;
  late String month;
  late int year;
  late String description;
  late DateTime createdAt;
  bool isSpent = false;
}
