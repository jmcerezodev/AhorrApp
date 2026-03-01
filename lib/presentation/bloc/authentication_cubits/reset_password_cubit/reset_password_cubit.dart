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
        status: ResetPasswordStatus.submitting,
        resetPassword: email,
        isValid: Formz.validate([email]),
      )
    );

    if (!state.isValid) {
      emit(state.copyWith(status: ResetPasswordStatus.failure, errorMessage: 'Formulario no válido'));
      return;
    }

    try {
      await _auth.resetPassword(state.resetPassword.value);
      emit(state.copyWith(status: ResetPasswordStatus.success));
    } catch (e) {
      emit(state.copyWith(status: ResetPasswordStatus.failure, errorMessage: 'Error al enviar el correo de recuperación'));
    }
  }

  void resetCubit() {
    emit(const ResetPasswordState());
  }

  void emailChanged(String value) {
    final email = Email.dirty(value: value);
    emit(state.copyWith(
      resetPassword: email,
      isValid: Formz.validate([email]),
      status: ResetPasswordStatus.initial,
    ));
  }
}
