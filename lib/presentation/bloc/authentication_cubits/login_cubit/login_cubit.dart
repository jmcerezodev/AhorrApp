import 'package:ahorrapp/core/inputs/inputs.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginCubitState> {
  final AuthAppwrite _auth = AuthAppwrite();

  LoginCubit() : super(const LoginCubitState());

  void onSubmit() async {
    final email = EmailLogin.dirty(value: state.email.value);
    final password = PasswordLogin.dirty(value: state.password.value);

    emit(
      state.copyWith(
        status: LoginStatus.submitting,
        email: email,
        password: password,
        isValid: Formz.validate([email, password]),
      )
    );

    if (!state.isValid) {
      emit(state.copyWith(status: LoginStatus.failure, errorMessage: 'Formulario no válido'));
      return;
    }

    try {
      final result = await _auth.signInEmailAndPassword(
        state.email.value, 
        state.password.value,
      );

      if (result is String) { // Éxito (retorna el userId)
        if (state.isRemember) {
          Preferences.email = state.email.value;
          Preferences.password = state.password.value;
        } else {
          Preferences.email = '';
          Preferences.password = '';
        }
        
        emit(state.copyWith(status: LoginStatus.success));
      } else {
        // Manejo de errores específicos según lo que retorna AuthAppwrite
        String message = 'Error al iniciar sesión';
        if (result == 0) message = 'Credenciales incorrectas';
        if (result == 3) message = 'Error de conexión con el servidor';
        
        emit(state.copyWith(status: LoginStatus.failure, errorMessage: message));
      }
    } catch (e) {
      emit(state.copyWith(status: LoginStatus.failure, errorMessage: 'Se ha producido un error inesperado'));
    }
  }

  void isRememberChanged(bool value) {
    emit(state.copyWith(isRemember: value, status: LoginStatus.initial));
  }

  void isPasswordVisible() {
    emit(state.copyWith(passwordEncripted: !state.passwordEncripted));
  }

  void resetCubit() {
    emit(const LoginCubitState());
  }

  void emailChanged(String value) {
    final email = EmailLogin.dirty(value: value);
    emit(state.copyWith(
      email: email,
      isValid: Formz.validate([email, state.password]),
      status: LoginStatus.initial,
    ));
  }

  void passwordChanged(String value) {
    final password = PasswordLogin.dirty(value: value);
    emit(state.copyWith(
      password: password,
      isValid: Formz.validate([password, state.email]),
      status: LoginStatus.initial,
    ));
  }
}
