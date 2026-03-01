import 'package:ahorrapp/core/inputs/inputs.dart';
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
    
    // Aquí se llamaría al repositorio para actualizar el nombre
    // Por ahora, simulamos el éxito si es válido
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

  void resetCubit() {
    emit(UpdateNameState(
      name: Preferences.name,
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
