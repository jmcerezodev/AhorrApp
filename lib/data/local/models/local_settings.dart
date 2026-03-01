import 'package:isar/isar.dart';

part 'local_settings.g.dart';

@collection
class LocalSettings {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String userId;

  double savingGoal = 0.0;
  double totalBalance = 0.0; // NUEVO: El balance ahora vive en Isar
}
