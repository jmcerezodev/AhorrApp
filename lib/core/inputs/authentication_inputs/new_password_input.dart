import 'package:formz/formz.dart';

enum NewPasswordError { empty, length, sameAsOld }

class NewPassword extends FormzInput<String, NewPasswordError> {
  final String oldPassword;

  // Ahora permite recibir un valor manteniendo el estado 'pure'
  const NewPassword.pure({String value = '', this.oldPassword = ''}) : super.pure(value);
  const NewPassword.dirty({required String value, this.oldPassword = ''}) : super.dirty(value);

  String? get errorMessage {
    if (isValid || isPure) return null;
    if (displayError == NewPasswordError.empty) return 'El campo es obligatorio';
    if (displayError == NewPasswordError.length) return 'Mínimo de 8 caracteres';
    if (displayError == NewPasswordError.sameAsOld) return 'Debe ser diferente a la actual';
    return null;
  }

  @override
  NewPasswordError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) return NewPasswordError.empty;
    if (value.length < 8) return NewPasswordError.length;
    if (value == oldPassword && oldPassword.isNotEmpty) return NewPasswordError.sameAsOld;

    return null;
  }
}
