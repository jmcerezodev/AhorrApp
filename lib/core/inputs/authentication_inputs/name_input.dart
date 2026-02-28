
import 'package:formz/formz.dart';

// Define input validation errors
enum NameError { empty, length }

// Extend FormzInput and provide the input type and error type.
class Name extends FormzInput<String, NameError> {

  // Call super.pure to represent an unmodified form input.
  const Name.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const Name.dirty({required String value}) : super.dirty(value);


  String? get errorMessage {
    
    if(isValid || isPure) return null;
    if(displayError == NameError.empty) return 'El Campo es obligatorio';
    if(displayError == NameError.length) return 'Nombre no valido';
    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  NameError? validator(String value) {
    
    if(value.isEmpty || value.trim().isEmpty) return NameError.empty;
    if((value.length < 2) || (value.length > 15)) return NameError.length;
    return null;
  }
}
