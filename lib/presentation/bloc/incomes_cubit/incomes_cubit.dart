import 'package:ahorrapp/core/inputs/inputs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

part 'incomes_cubit_state.dart';

class IncomesCubit extends Cubit<IncomesCubitState> {
  IncomesCubit() : super(const IncomesCubitState());

   void onSubmit(){
    emit(
      state.copyWhith(
        formStatus: FormStatusIncomes.validating,
        incomeName: IncomeNameInput.dirty(value: state.incomeName.value),
        incomeMoney: IncomeMoneyInput.dirty(value: state.incomeMoney.value),
        isValid: Formz.validate([
          state.incomeMoney,
          state.incomeName,
        ]),
      )
    );
   }

   void resetCubit(){
    emit(
      state.copyWhith(
        incomeName: const IncomeNameInput.pure(),
        incomeMoney: const IncomeMoneyInput.pure(),
      )
    );
   }

   void incomeNameChanged(String value){
    final incomeName = IncomeNameInput.dirty(value: value);
    emit(
      state.copyWhith(
        incomeName: incomeName,
        isValid: Formz.validate([ incomeName, state.incomeMoney ]),
      )
    );    
  }

  void incomeMoneyChanged(String value){
    final incomeMoney = IncomeMoneyInput.dirty(value: value);
    emit(
      state.copyWhith(
        incomeMoney: incomeMoney,
        isValid: Formz.validate([incomeMoney, state.incomeName]),
      )
    );    
  }
  
}

