import 'package:isar/isar.dart';

part 'local_recurrent_expense.g.dart';

enum LocalRecurrentFrequency { monthly, quarterly, semiAnnually, annually }

@collection
class LocalRecurrentExpense {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String appwriteId;

  late String userId;
  late String name;
  late double money;
  int? day;
  late String category;
  late bool isActive;
  
  String? lastApplied;

  @enumerated
  late LocalRecurrentFrequency frequency;

  late DateTime startDate; 

  late DateTime createdAt;

  late int position; 

  late bool includeInSummary; // NUEVO: Para incluir o no en el resumen
}
