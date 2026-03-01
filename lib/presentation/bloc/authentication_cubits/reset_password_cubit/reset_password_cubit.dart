import 'package:ahorrapp/core/inputs/inputs.dart';
import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

part 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final AuthAppwrite _auth = AuthAppwrite();

  ResetPasswordCubit() : super(const ResetPasswordState());

  void onSubmit() async {
    final email = Email.dirty(value: state.resetPassword.value);

    emit(
      state.copyWith(
        formStatus: FormStatusResetPassword.validating,
        resetPassword: email,
        isValid: Formz.validate([email]),
      )
    );

    if (!state.isValid) {
      emit(state.copyWith(formStatus: FormStatusResetPassword.invalid));
      return;
    }

    try {
      await _auth.resetPassword(state.resetPassword.value);
      emit(state.copyWith(formStatus: FormStatusResetPassword.valid));
    } catch (e) {
      emit(state.copyWith(formStatus: FormStatusResetPassword.invalid));
    }
  }

  void resetCubit() {
    emit(state.copyWith(
      resetPassword: const Email.pure(),
      formStatus: FormStatusResetPassword.invalid,
    ));
  }

  void emailChanged(String value) {
    final email = Email.dirty(value: value);
    emit(state.copyWith(
      resetPassword: email,
      isValid: Formz.validate([email]),
    ));
  }
}
