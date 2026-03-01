part of 'incomes_cubit.dart';

enum FormStatusIncomes {invalid, valid, validating}

class IncomesCubitState extends Equatable {

  final FormStatusIncomes formStatus;
  final bool isValid;
  final IncomeNameInput incomeName;
  final IncomeMoneyInput incomeMoney;

  const IncomesCubitState({
    this.formStatus = FormStatusIncomes.invalid,
    this.isValid = false,
    this.incomeName = const IncomeNameInput.pure(),
    this.incomeMoney = const IncomeMoneyInput.pure(),
  });

  IncomesCubitState copyWith({
    FormStatusIncomes? formStatus,
    bool? isValid,
    IncomeNameInput? incomeName,
    IncomeMoneyInput? incomeMoney,
  }) => IncomesCubitState(
    formStatus: formStatus ?? this.formStatus,
    isValid: isValid ?? this.isValid,
    incomeName: incomeName ?? this.incomeName,
    incomeMoney: incomeMoney ?? this.incomeMoney,
  );
  
  @override
  List<Object?> get props => [
    formStatus,
    isValid,
    incomeName,
    incomeMoney,
  ];
}
