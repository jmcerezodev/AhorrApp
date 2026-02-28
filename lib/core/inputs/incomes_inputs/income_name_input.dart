import 'package:formz/formz.dart';

// Define input validation errors
enum IncomesNameError { empty }

// Extend FormzInput and provide the input type and error type.
class IncomeNameInput extends FormzInput<String, IncomesNameError> {

  // Call super.pure to represent an unmodified form input.
  const IncomeNameInput.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const IncomeNameInput.dirty({required String value}) : super.dirty(value);

  String? get errorMessage {
    
    if(isValid || isPure) return null;
    if(displayError == IncomesNameError.empty) return 'El Campo es obligatorio';
    //if(displayError == UserNameError.length) return 'Minimo de 6 letras';
    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  IncomesNameError? validator(String value) {
    
    if(value.isEmpty || value.trim().isEmpty) return IncomesNameError.empty;
    //if(value.length < 6) return UserNameError.length;

    return null;
  }
}