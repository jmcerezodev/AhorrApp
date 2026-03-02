import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:ahorrapp/domain/repositories/i_recurrent_expense_repository.dart';

class GetRecurrentExpensesUseCase {
  final IRecurrentExpenseRepository localRepository;

  GetRecurrentExpensesUseCase({required this.localRepository});

  Future<List<RecurrentExpense>> call(String userId) async {
    return await localRepository.getRecurrentExpenses(userId);
  }
}
