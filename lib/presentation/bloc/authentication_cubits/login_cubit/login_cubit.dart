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
        formStatus: FormStatusLogin.validating,
        email: email,
        password: password,
        isValid: Formz.validate([email, password]),
      )
    );

    if (!state.isValid) {
      emit(state.copyWith(formStatus: FormStatusLogin.invalid));
      return;
    }

    try {
      final result = await _auth.signInEmailAndPassword(
        state.email.value, 
        state.password.value,
      );

      if (result is String) { // Éxito (retorna el userId)
        // Guardar credenciales si el usuario marcó "Recordarme"
        if (state.isRemember) {
          Preferences.email = state.email.value;
          Preferences.password = state.password.value;
        } else {
          Preferences.email = '';
          Preferences.password = '';
        }
        
        emit(state.copyWith(formStatus: FormStatusLogin.valid));
      } else {
        emit(state.copyWith(formStatus: FormStatusLogin.invalid));
      }
    } catch (e) {
      emit(state.copyWith(formStatus: FormStatusLogin.invalid));
    }
  }

  void isRememberChanged(bool value) {
    emit(state.copyWith(isRemember: value));
  }

  void isPasswordVisible() {
    emit(state.copyWith(passwordEncripted: !state.passwordEncripted));
  }

  void resetCubit() {
    emit(state.copyWith(
      email: const EmailLogin.pure(),
      password: const PasswordLogin.pure(),
      formStatus: FormStatusLogin.editing,
      isRemember: false,
    ));
  }

  void emailChanged(String value) {
    final email = EmailLogin.dirty(value: value);
    emit(state.copyWith(
      email: email,
      isValid: Formz.validate([email, state.password]),
      formStatus: FormStatusLogin.editing,
    ));
  }

  void passwordChanged(String value) {
    final password = PasswordLogin.dirty(value: value);
    emit(state.copyWith(
      password: password,
      isValid: Formz.validate([password, state.email]),
      formStatus: FormStatusLogin.editing,
    ));
  }
}
