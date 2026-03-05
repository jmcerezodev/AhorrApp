part of 'incomes_cubit.dart';

enum IncomesStatus { initial, posting, success, failure }

class IncomesCubitState extends Equatable {
  final IncomesStatus status;
  final bool isValid;
  final IncomeNameInput incomeName;
  final IncomeMoneyInput incomeMoney;
  final String category; 
  final String? errorMessage;

  const IncomesCubitState({
    this.status = IncomesStatus.initial,
    this.isValid = false,
    this.incomeName = const IncomeNameInput.pure(),
    this.incomeMoney = const IncomeMoneyInput.pure(),
    this.category = 'otro', // CORREGIDO: De 'general' a 'otro' para coincidir con la lista de IncomesDialog
    this.errorMessage,
  });

  IncomesCubitState copyWith({
    IncomesStatus? status,
    bool? isValid,
    IncomeNameInput? incomeName,
    IncomeMoneyInput? incomeMoney,
    String? category,
    String? errorMessage,
  }) =>
      IncomesCubitState(
        status: status ?? this.status,
        isValid: isValid ?? this.isValid,
        incomeName: incomeName ?? this.incomeName,
        incomeMoney: incomeMoney ?? this.incomeMoney,
        category: category ?? this.category,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, isValid, incomeName, incomeMoney, category, errorMessage];
}
