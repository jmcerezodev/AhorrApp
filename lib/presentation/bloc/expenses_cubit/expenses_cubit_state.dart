part of 'expenses_cubit.dart';

enum FormStatusExpenses {invalid, valid, validating}

class ExpensesCubitState {

  final bool isValid;
  final FormStatusExpenses formStatus;
  final ExpenseNameInput expenseName;
  final ExpenseMoneyInput expenseMoney;

  const ExpensesCubitState({
    this.isValid = false,
    this.formStatus = FormStatusExpenses.invalid,
    this.expenseMoney = const ExpenseMoneyInput.pure(),
    this.expenseName = const ExpenseNameInput.pure(),
  });

  ExpensesCubitState copyWhith({
    FormStatusExpenses? formStatus,
    bool? isValid,
    ExpenseNameInput? expenseName,
    ExpenseMoneyInput? expenseMoney,
  }) => ExpensesCubitState(
    formStatus: formStatus ?? this.formStatus,
    isValid: isValid ?? this.isValid,
    expenseName: expenseName ?? this.expenseName,
    expenseMoney: expenseMoney ?? this.expenseMoney,
  );
}



