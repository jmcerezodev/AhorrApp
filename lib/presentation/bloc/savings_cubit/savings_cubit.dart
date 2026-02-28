import 'package:ahorrapp/core/inputs/inputs.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

part 'savings_cubit_state.dart';

class SavingsCubit extends Cubit<SavingsCubitState> {
  SavingsCubit() : super(const SavingsCubitState());

   void onSubmit(){
    emit(
      state.copyWhith(
        formStatus: FormStatusSavings.validating,
        saving: SavingInput.dirty(value: state.saving.value),
        savingTotal: state.savingTotal + (double.tryParse(state.saving.value) ?? 0),
        isValid: Formz.validate([
          state.saving,
        ])
      )
    );
    // Aquí puedes añadir la lógica para persistir en Appwrite
   }

   void deleteSavings() {
    emit(state.copyWhith(
      savingTotal: 0.0,
      saving: const SavingInput.pure(),
    ));
    // Aquí puedes añadir la lógica para borrar en Appwrite
   }

   void resetCubit(){
    emit(
      state.copyWhith(
        saving: const SavingInput.pure(),
      )
    );
   }

  void savingChanged(String value){
    final saving = SavingInput.dirty(value: value);
    emit(
      state.copyWhith(
        saving: saving,
        isValid: Formz.validate([saving]),
      )
    );    
  }

  void savingTotal(double value){
    emit(
      state.copyWhith(
        savingTotal: value
      )
    );    
  }
}
