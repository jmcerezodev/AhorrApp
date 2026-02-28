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
    final newPassword = NewPassword.dirty(value: state.newPassword.value);
    final confirmedPassword = ConfirmedPassword.dirty(
      value: state.confirmedPassword.value,
      originalPassword: newPassword.value
    );

    emit(
      state.copyWhith(
        formStatus: FormStatusUpdatePassword.validating,
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmedPassword: confirmedPassword,
        isValid: Formz.validate([currentPassword, newPassword, confirmedPassword]),
      )
    );

    if (!state.isValid) {
      emit(state.copyWhith(formStatus: FormStatusUpdatePassword.invalid));
      return;
    }

    try {
      await _auth.updatePassword(
        context, 
        state.newPassword.value, 
        state.currentPassword.value
      );
      emit(state.copyWhith(formStatus: FormStatusUpdatePassword.valid));
    } catch (e) {
      emit(state.copyWhith(formStatus: FormStatusUpdatePassword.invalid));
    }
  }

  void resetCubit() {
    emit(state.copyWhith(
      currentPassword: const Password.pure(),
      newPassword: const NewPassword.pure(),
      confirmedPassword: const ConfirmedPassword.pure(),
      formStatus: FormStatusUpdatePassword.invalid,
    ));
  }

  void isCurrentPasswordVisible(bool value) {
    emit(state.copyWhith(currentPasswordEncripted: !state.currentPasswordEncripted));
  }

  void isNewPasswordVisible(bool value) {
    emit(state.copyWhith(newPasswordEncripted: !state.newPasswordEncripted));
  }

  void isConfirmedPasswordVisible(bool value) {
    emit(state.copyWhith(confirmedPasswordEncripted: !state.confirmedPasswordEncripted));
  }

  void currentPasswordChanged(String value) {
    final currentPassword = Password.dirty(value: value);
    emit(state.copyWhith(
      currentPassword: currentPassword,
      isValid: Formz.validate([currentPassword, state.newPassword, state.confirmedPassword]),
    ));
  }

  void newPasswordChanged(String value) {
    final newPassword = NewPassword.dirty(value: value);
    // Actualizamos también la confirmación para que compare contra el nuevo valor
    final confirmedPassword = ConfirmedPassword.dirty(
      value: state.confirmedPassword.value,
      originalPassword: newPassword.value
    );
    
    emit(state.copyWhith(
      newPassword: newPassword,
      confirmedPassword: confirmedPassword,
      isValid: Formz.validate([newPassword, state.currentPassword, confirmedPassword]),
    ));
  }

  void confirmedPasswordChanged(String value) {
    final confirmedPassword = ConfirmedPassword.dirty(
      value: value,
      originalPassword: state.newPassword.value
    );
    emit(state.copyWhith(
      confirmedPassword: confirmedPassword,
      isValid: Formz.validate([confirmedPassword, state.currentPassword, state.newPassword]),
    ));
  }
}
