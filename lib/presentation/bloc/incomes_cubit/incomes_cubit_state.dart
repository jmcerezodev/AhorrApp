part of 'incomes_cubit.dart';

enum IncomesStatus { initial, posting, success, failure }

class IncomesCubitState extends Equatable {
  final IncomesStatus status;
  final bool isValid;
  final IncomeNameInput incomeName;
  final IncomeMoneyInput incomeMoney;
  final String? errorMessage;

  const IncomesCubitState({
    this.status = IncomesStatus.initial,
    this.isValid = false,
    this.incomeName = const IncomeNameInput.pure(),
    this.incomeMoney = const IncomeMoneyInput.pure(),
    this.errorMessage,
  });

  IncomesCubitState copyWith({
    IncomesStatus? status,
    bool? isValid,
    IncomeNameInput? incomeName,
    IncomeMoneyInput? incomeMoney,
    String? errorMessage,
  }) =>
      IncomesCubitState(
        status: status ?? this.status,
        isValid: isValid ?? this.isValid,
        incomeName: incomeName ?? this.incomeName,
        incomeMoney: incomeMoney ?? this.incomeMoney,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, isValid, incomeName, incomeMoney, errorMessage];
}
