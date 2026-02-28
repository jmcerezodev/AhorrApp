import 'package:formz/formz.dart';

// Define input validation errors
enum IncomeMoneyError { empty, format }

// Extend FormzInput and provide the input type and error type.
class IncomeMoneyInput extends FormzInput<String, IncomeMoneyError> {

  static final RegExp incomeMoneyRegExp = RegExp(r'^[0-9]+(\.[0-9]+)?[0-9]*$');
  // Call super.pure to represent an unmodified form input.
  const IncomeMoneyInput.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const IncomeMoneyInput.dirty({required String value}) : super.dirty(value);

  String? get errorMessage {
    
    if(isValid || isPure) return null;
    if(displayError == IncomeMoneyError.empty) return 'El Campo es obligatorio';
    if(displayError == IncomeMoneyError.format) return 'Numero no valido';
    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  IncomeMoneyError? validator(String value) {
    
    if(value.isEmpty || value.trim().isEmpty) return IncomeMoneyError.empty;
    if(!incomeMoneyRegExp.hasMatch(value)) return IncomeMoneyError.format;

    return null;
  }
}