
import 'package:formz/formz.dart';

// Define input validation errors
enum EmailLoginError { empty, }

// Extend FormzInput and provide the input type and error type.
class EmailLogin extends FormzInput<String, EmailLoginError> {

  // Call super.pure to represent an unmodified form input.
  const EmailLogin.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const EmailLogin.dirty({required String value}) : super.dirty(value);


  String? get errorMessage {
    
    if(isValid || isPure) return null;
    if(displayError == EmailLoginError.empty) return 'El Campo es obligatorio';
    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  EmailLoginError? validator(String value) {
    
    if(value.isEmpty || value.trim().isEmpty) return EmailLoginError.empty;
    return null;
  }
}
