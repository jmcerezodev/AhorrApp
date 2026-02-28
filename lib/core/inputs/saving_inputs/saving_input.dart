import 'package:formz/formz.dart';

// Define input validation errors
enum SavingError { empty, format }

// Extend FormzInput and provide the input type and error type.
class SavingInput extends FormzInput<String, SavingError> {

  static final RegExp savingRegExp = RegExp(r'^[0-9.]+$');
  // Call super.pure to represent an unmodified form input.
  const SavingInput.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const SavingInput.dirty({required String value}) : super.dirty(value);

  String? get errorMessage {
    
    if(isValid || isPure) return null;
    if(displayError == SavingError.empty) return 'El Campo es obligatorio';
    if(displayError == SavingError.format) return 'Numero no valido';
    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  SavingError? validator(String value) {
    
    if(value.isEmpty || value.trim().isEmpty) return SavingError.empty;
    if(!savingRegExp.hasMatch(value)) return SavingError.format;

    return null;
  }
}