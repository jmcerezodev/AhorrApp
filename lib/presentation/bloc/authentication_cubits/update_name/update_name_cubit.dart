import 'package:ahorrapp/core/inputs/authentication_inputs/name_input.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

part 'update_name_state.dart';

class UpdateNameCubit extends Cubit<UpdateNameState> {
  UpdateNameCubit() : super(UpdateNameState(name: Preferences.name));

  void onSubmit() {
    if (!state.isValid) return;
    emit(state.copyWith(status: UpdateNameStatus.submitting));
    onUpdateSuccess(state.newName.value);
  }

  void onUpdateSuccess(String newName) {
    Preferences.name = newName;
    emit(state.copyWith(
      name: newName,
      status: UpdateNameStatus.success,
      newName: const Name.pure(),
    ));
  }

  // REINICIO MAESTRO MEJORADO
  void resetCubit() {
    emit(UpdateNameState(
      name: Preferences.name, // Tomará el valor vacío o el nuevo tras el login
      newName: const Name.pure(),
      status: UpdateNameStatus.initial,
    ));
  }

  void newNameChanged(String value) {
    final newName = Name.dirty(value: value);
    emit(
      state.copyWith(
        newName: newName,
        isValid: Formz.validate([newName]),
        status: UpdateNameStatus.initial,
      )
    );    
  }
}
