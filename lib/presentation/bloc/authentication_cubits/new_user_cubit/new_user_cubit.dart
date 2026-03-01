import 'package:ahorrapp/core/inputs/authentication_inputs/name_input.dart';
import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ahorrapp/core/inputs/authentication_inputs/email_input.dart';
import 'package:ahorrapp/core/inputs/authentication_inputs/password_input.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

part 'new_user_state.dart';

class NewUserCubit extends Cubit<NewUserCubitState> {
  final AuthAppwrite _auth = AuthAppwrite();

  NewUserCubit() : super(const NewUserCubitState());

  void onSubmit() async {
    final name = Name.dirty(value: state.name.value);
    final email = Email.dirty(value: state.email.value);
    final password = Password.dirty(value: state.password.value);

    emit(
      state.copyWith(
        formStatus: FormStatusNewUser.validating,
        name: name,
        email: email,
        password: password,
        isValid: Formz.validate([name, email, password]),
      )
    );

    if (!state.isValid) {
      emit(state.copyWith(formStatus: FormStatusNewUser.invalid));
      return;
    }

    try {
      final result = await _auth.createAcount(
        state.email.value,
        state.password.value,
        state.name.value,
      );

      if (result is String) { // Éxito (retorna el userId)
        emit(state.copyWith(formStatus: FormStatusNewUser.valid));
      } else if (result == 1) {
        // Podrías manejar errores específicos aquí (ej. email ya en uso)
        emit(state.copyWith(formStatus: FormStatusNewUser.invalid));
      } else {
        emit(state.copyWith(formStatus: FormStatusNewUser.invalid));
      }
    } catch (e) {
      emit(state.copyWith(formStatus: FormStatusNewUser.invalid));
    }
  }

  void resetCubit() {
    emit(state.copyWith(
      name: const Name.pure(),
      email: const Email.pure(),
      password: const Password.pure(),
      formStatus: FormStatusNewUser.invalid,
    ));
  }

  void isPasswordVisible() {
    emit(state.copyWith(passwordEncripted: !state.passwordEncripted));
  }

  void nameChanged(String value) {
    final name = Name.dirty(value: value);
    emit(state.copyWith(
      name: name,
      isValid: Formz.validate([name, state.email, state.password]),
    ));
  }

  void emailChanged(String value) {
    final email = Email.dirty(value: value);
    emit(state.copyWith(
      email: email,
      isValid: Formz.validate([email, state.name, state.password]),
    ));
  }

  void passwordChanged(String value) {
    final password = Password.dirty(value: value);
    emit(state.copyWith(
      password: password,
      isValid: Formz.validate([password, state.name, state.email]),
    ));
  }
}
