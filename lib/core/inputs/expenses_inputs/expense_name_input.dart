import 'package:formz/formz.dart';

// Define input validation errors
enum ExpenseNameError { empty }

// Extend FormzInput and provide the input type and error type.
class ExpenseNameInput extends FormzInput<String, ExpenseNameError> {

  // Call super.pure to represent an unmodified form input.
  const ExpenseNameInput.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const ExpenseNameInput.dirty({required String value}) : super.dirty(value);

  String? get errorMessage {
    
    if(isValid || isPure) return null;
    if(displayError == ExpenseNameError.empty) return 'El Campo es obligatorio';
    //if(displayError == UserNameError.length) return 'Minimo de 6 letras';
    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  ExpenseNameError? validator(String value) {
    
    if(value.isEmpty || value.trim().isEmpty) return ExpenseNameError.empty;
    //if(value.length < 6) return UserNameError.length;

    return null;
  }
}