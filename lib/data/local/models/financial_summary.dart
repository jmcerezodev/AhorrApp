import 'package:isar/isar.dart';

part 'financial_summary.g.dart';

@collection
class FinancialSummary {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String userId;

  double savingGoal = 0.0;
  double totalBalance = 0.0; 
}
