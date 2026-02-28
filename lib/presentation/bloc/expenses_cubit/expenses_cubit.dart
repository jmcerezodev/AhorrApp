import 'package:ahorrapp/core/inputs/inputs.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

part 'expenses_cubit_state.dart';

class ExpensesCubit extends Cubit<ExpensesCubitState> {
  ExpensesCubit() : super(const ExpensesCubitState());

   void onSubmit(){
    emit(
      state.copyWhith(
        formStatus: FormStatusExpenses.validating,
        expenseName: ExpenseNameInput.dirty(value: state.expenseName.value),
        expenseMoney: ExpenseMoneyInput.dirty(value: state.expenseMoney.value),
        isValid: Formz.validate([
          state.expenseName,
          state.expenseMoney,
        ]),
      )
    );
   }

   void resetCubit(){
    emit(
      state.copyWhith(
        expenseName: const ExpenseNameInput.pure(),
        expenseMoney: const ExpenseMoneyInput.pure(),
      )
    );
    
   }

   void expenseNameChanged(String value){
    final expenseName = ExpenseNameInput.dirty(value: value);
    emit(
      state.copyWhith(
        expenseName: expenseName,
        isValid: Formz.validate([ expenseName, state.expenseMoney ]),
      )
    );    
  }

  void expenseMoneyChanged(String value){
    final expenseMoney = ExpenseMoneyInput.dirty(value: value);
    emit(
      state.copyWhith(
        expenseMoney: expenseMoney,
        isValid: Formz.validate([ expenseMoney, state.expenseName]),
      )
    );    
  }
}

