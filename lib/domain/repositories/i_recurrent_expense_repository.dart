import '../entities/recurrent_expense.dart';

abstract class IRecurrentExpenseRepository {
  Future<List<RecurrentExpense>> getRecurrentExpenses(String userId);
  Future<void> saveRecurrentExpense(RecurrentExpense expense);
  Future<void> deleteRecurrentExpense(String id);
  Future<void> updateLastApplied(String id, String monthYear);
}
