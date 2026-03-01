import 'package:ahorrapp/core/inputs/inputs.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

part 'update_name_state.dart';

class UpdateNameCubit extends Cubit<UpdateNameState> {
  UpdateNameCubit() : super(UpdateNameState(name: Preferences.name));

  void onSubmit() {
    emit(
      state.copyWhith(
        formStatus: FormStatusUpdateName.validating,
        newName: Name.dirty(value: state.newName.value),
        isValid: Formz.validate([state.newName]),
      )
    );
  }

  void onUpdateSuccess(String newName) {
    emit(state.copyWhith(
      name: newName,
      formStatus: FormStatusUpdateName.valid,
      newName: const Name.pure(),
    ));
  }

  void resetCubit() {
    emit(state.copyWhith(
      newName: const Name.pure(),
      formStatus: FormStatusUpdateName.invalid,
    ));
  }

  void newNameChanged(String value) {
    final newName = Name.dirty(value: value);
    emit(
      state.copyWhith(
        newName: newName,
        isValid: Formz.validate([newName]),
      )
    );    
  }
}
