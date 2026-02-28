
import 'package:formz/formz.dart';

// Define input validation errors
enum ResetPasswordError { empty, format }

// Extend FormzInput and provide the input type and error type.
class ResetPassword extends FormzInput<String, ResetPasswordError> {

  static final RegExp resetPasswordRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  // Call super.pure to represent an unmodified form input.
  const ResetPassword.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const ResetPassword.dirty({required String value}) : super.dirty(value);


  String? get errorMessage {
    
    if(isValid || isPure) return null;
    if(displayError == ResetPasswordError.empty) return 'El Campo es obligatorio';
    if(displayError == ResetPasswordError.format) return 'Correo no valido';
    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  ResetPasswordError? validator(String value) {
    
    if(value.isEmpty || value.trim().isEmpty) return ResetPasswordError.empty;
    if(!resetPasswordRegExp.hasMatch(value)) return ResetPasswordError.format;
    return null;
  }
}
