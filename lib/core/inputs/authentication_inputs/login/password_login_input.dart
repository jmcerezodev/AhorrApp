
import 'package:formz/formz.dart';

// Define input validation errors
enum PasswordLoginError { empty,}

// Extend FormzInput and provide the input type and error type.
class PasswordLogin extends FormzInput<String, PasswordLoginError> {
  // Call super.pure to represent an unmodified form input.
  const PasswordLogin.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const PasswordLogin.dirty({required String value}) : super.dirty(value);

  String? get errorMessage{

    if(isValid || isPure) return null;
    if(displayError == PasswordLoginError.empty) return 'El Campo es obligatorio';
    return null;

  }

  // Override validator to handle validating a given input value.
  @override
  PasswordLoginError? validator(String value) {
    
    if(value.isEmpty || value.trim().isEmpty) return PasswordLoginError.empty;

    return null;
  }
}
