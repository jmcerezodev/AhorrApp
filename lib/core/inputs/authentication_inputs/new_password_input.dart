
import 'package:formz/formz.dart';

// Define input validation errors
enum NewPasswordError { empty, length }

// Extend FormzInput and provide the input type and error type.
class NewPassword extends FormzInput<String, NewPasswordError> {
  // Call super.pure to represent an unmodified form input.
  const NewPassword.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const NewPassword.dirty({required String value}) : super.dirty(value);

  String? get errorMessage{

    if(isValid || isPure) return null;
    if(displayError == NewPasswordError.empty) return 'El Campo es obligatorio';
    if(displayError == NewPasswordError.length) return 'Minimo de 6 letras';
    return null;

  }

  // Override validator to handle validating a given input value.
  @override
  NewPasswordError? validator(String value) {
    
    if(value.isEmpty || value.trim().isEmpty) return NewPasswordError.empty;
    if(value.length < 6) return NewPasswordError.length;

    return null;
  }
}
