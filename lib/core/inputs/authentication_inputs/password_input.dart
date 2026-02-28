import 'package:formz/formz.dart';

enum PasswordError { empty, length }

class Password extends FormzInput<String, PasswordError> {
  // Ahora permite recibir un valor manteniendo el estado 'pure'
  const Password.pure([String value = '']) : super.pure(value);
  const Password.dirty({required String value}) : super.dirty(value);

  String? get errorMessage {
    if (isValid || isPure) return null;
    if (displayError == PasswordError.empty) return 'El campo es obligatorio';
    if (displayError == PasswordError.length) return 'Mínimo de 8 letras';
    return null;
  }

  @override
  PasswordError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) return PasswordError.empty;
    if (value.length < 8) return PasswordError.length;
    return null;
  }
}
