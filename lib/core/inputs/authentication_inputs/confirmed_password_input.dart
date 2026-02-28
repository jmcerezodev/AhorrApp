import 'package:formz/formz.dart';

enum ConfirmedPasswordError { empty, length, mismatch }

class ConfirmedPassword extends FormzInput<String, ConfirmedPasswordError> {
  final String originalPassword;

  const ConfirmedPassword.pure({this.originalPassword = ''}) : super.pure('');
  const ConfirmedPassword.dirty({required String value, this.originalPassword = ''}) : super.dirty(value);

  String? get errorMessage {
    if (isValid || isPure) return null;
    if (displayError == ConfirmedPasswordError.empty) return 'El campo es obligatorio';
    if (displayError == ConfirmedPasswordError.length) return 'Mínimo de 6 caracteres';
    if (displayError == ConfirmedPasswordError.mismatch) return 'Las contraseñas no coinciden';
    return null;
  }

  @override
  ConfirmedPasswordError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) return ConfirmedPasswordError.empty;
    if (value.length < 6) return ConfirmedPasswordError.length;
    if (value != originalPassword) return ConfirmedPasswordError.mismatch;

    return null;
  }
}
