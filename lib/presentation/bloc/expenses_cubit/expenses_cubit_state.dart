part of 'expenses_cubit.dart';

enum ExpensesStatus { initial, posting, success, failure }

class ExpensesCubitState extends Equatable {
  final bool isValid;
  final ExpensesStatus status;
  final ExpenseNameInput expenseName;
  final ExpenseMoneyInput expenseMoney;
  final String category; // NUEVO
  final String? errorMessage;

  const ExpensesCubitState({
    this.isValid = false,
    this.status = ExpensesStatus.initial,
    this.expenseMoney = const ExpenseMoneyInput.pure(),
    this.expenseName = const ExpenseNameInput.pure(),
    this.category = 'general', // NUEVO
    this.errorMessage,
  });

  ExpensesCubitState copyWith({
    ExpensesStatus? status,
    bool? isValid,
    ExpenseNameInput? expenseName,
    ExpenseMoneyInput? expenseMoney,
    String? category,
    String? errorMessage,
  }) =>
      ExpensesCubitState(
        status: status ?? this.status,
        isValid: isValid ?? this.isValid,
        expenseName: expenseName ?? this.expenseName,
        expenseMoney: expenseMoney ?? this.expenseMoney,
        category: category ?? this.category,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, isValid, expenseName, expenseMoney, category, errorMessage];
}
