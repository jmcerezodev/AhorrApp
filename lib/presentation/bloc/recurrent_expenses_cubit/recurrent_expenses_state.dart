part of 'recurrent_expenses_cubit.dart';

enum RecurrentExpensesStatus { initial, loading, success, failure }

class RecurrentExpensesState extends Equatable {
  final List<RecurrentExpense> expenses;
  final RecurrentExpensesStatus status;
  final String? errorMessage;

  const RecurrentExpensesState({
    this.expenses = const [],
    this.status = RecurrentExpensesStatus.initial,
    this.errorMessage,
  });

  RecurrentExpensesState copyWith({
    List<RecurrentExpense>? expenses,
    RecurrentExpensesStatus? status,
    String? errorMessage,
  }) {
    return RecurrentExpensesState(
      expenses: expenses ?? this.expenses,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [expenses, status, errorMessage];
}
