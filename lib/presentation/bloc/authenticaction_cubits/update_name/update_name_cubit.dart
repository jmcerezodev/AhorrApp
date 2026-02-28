import 'package:ahorrapp/core/inputs/inputs.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

part 'update_name_state.dart';

class UpdateNameCubit extends Cubit<UpdateNameState> {
  UpdateNameCubit() : super(const UpdateNameState());

  void onSubmit(){
    emit(
      state.copyWhith(
        formStatus: FormStatusUpdateName.validating,
        newName: Name.dirty(value: state.newName.value),
        isValid: Formz.validate([
          state.newName,
        ]),
      )
    );
   }

  void resetCubit(){
    emit(
      state.copyWhith(
        newName: const Name.pure(),
      )
    );
   }

   void name(String value){
    emit(state.copyWhith(
      name: value,
    ));
   }

  void newNameChanged(String value){
    final newName = Name.dirty(value: value);
    emit(
      state.copyWhith(
        newName: newName,
        isValid: Formz.validate([newName]),
      )
    );    
  }
}
