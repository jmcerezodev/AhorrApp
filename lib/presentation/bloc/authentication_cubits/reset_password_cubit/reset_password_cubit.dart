import 'package:ahorrapp/core/inputs/inputs.dart';
import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:appwrite/appwrite.dart';
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
    } on AppwriteException catch (e) {
      String message = 'Error: ${e.message}'; // Mostramos el mensaje real de Appwrite
      if (e.code == 404) message = 'El correo electrónico no está registrado';
      if (e.code == 429) message = 'Demasiados intentos. Espera unos minutos';
      
      emit(state.copyWith(
        status: ResetPasswordStatus.failure, 
        errorMessage: message
      ));
    } catch (e) {
      emit(state.copyWith(status: ResetPasswordStatus.failure, errorMessage: 'Error inesperado: $e'));
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
