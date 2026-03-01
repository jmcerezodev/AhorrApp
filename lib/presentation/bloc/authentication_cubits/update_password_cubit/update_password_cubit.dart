import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahorrapp/core/inputs/inputs.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

part 'update_password_state.dart';

class UpdatePasswordCubit extends Cubit<UpdatePasswordState> {
  final AuthAppwrite _auth = AuthAppwrite();

  UpdatePasswordCubit() : super(const UpdatePasswordState());

  void onSubmit(BuildContext context) async {
    final currentPassword = Password.dirty(value: state.currentPassword.value);
    final newPassword = NewPassword.dirty(
      value: state.newPassword.value,
      oldPassword: currentPassword.value
    );
    final confirmedPassword = ConfirmedPassword.dirty(
      value: state.confirmedPassword.value,
      originalPassword: newPassword.value
    );

    final isValid = Formz.validate([currentPassword, newPassword, confirmedPassword]);

    emit(
      state.copyWith(
        status: UpdatePasswordStatus.submitting,
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmedPassword: confirmedPassword,
        isValid: isValid,
      )
    );

    if (!isValid) {
      emit(state.copyWith(status: UpdatePasswordStatus.failure, errorMessage: 'Formulario no válido'));
      return;
    }

    try {
      await _auth.updatePassword(
        context, 
        state.newPassword.value, 
        state.currentPassword.value
      );
      emit(state.copyWith(status: UpdatePasswordStatus.success));
    } catch (e) {
      emit(state.copyWith(status: UpdatePasswordStatus.failure, errorMessage: 'Error al actualizar la contraseña'));
    }
  }

  void resetCubit() {
    emit(const UpdatePasswordState());
  }

  void isCurrentPasswordVisible() {
    emit(state.copyWith(currentPasswordEncripted: !state.currentPasswordEncripted));
  }

  void isNewPasswordVisible() {
    emit(state.copyWith(newPasswordEncripted: !state.newPasswordEncripted));
  }

  void isConfirmedPasswordVisible() {
    emit(state.copyWith(confirmedPasswordEncripted: !state.confirmedPasswordEncripted));
  }

  void currentPasswordChanged(String value) {
    final currentPassword = Password.dirty(value: value);
    emit(state.copyWith(
      currentPassword: currentPassword,
      isValid: Formz.validate([currentPassword, state.newPassword, state.confirmedPassword]),
      status: UpdatePasswordStatus.initial,
    ));
  }

  void newPasswordChanged(String value) {
    final newPassword = NewPassword.dirty(
      value: value,
      oldPassword: state.currentPassword.value
    );
    final confirmedPassword = ConfirmedPassword.dirty(
      value: state.confirmedPassword.value,
      originalPassword: newPassword.value
    );
    
    emit(state.copyWith(
      newPassword: newPassword,
      confirmedPassword: confirmedPassword,
      isValid: Formz.validate([newPassword, state.currentPassword, confirmedPassword]),
      status: UpdatePasswordStatus.initial,
    ));
  }

  void confirmedPasswordChanged(String value) {
    final confirmedPassword = ConfirmedPassword.dirty(
      value: value,
      originalPassword: state.newPassword.value
    );
    emit(state.copyWith(
      confirmedPassword: confirmedPassword,
      isValid: Formz.validate([confirmedPassword, state.currentPassword, state.newPassword]),
      status: UpdatePasswordStatus.initial,
    ));
  }
}
