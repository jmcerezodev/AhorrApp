import 'package:formz/formz.dart';

// Define input validation errors
enum ExpenseMoneyError { empty, format }

// Extend FormzInput and provide the input type and error type.
class ExpenseMoneyInput extends FormzInput<String, ExpenseMoneyError> {

  static final RegExp expenseRegExp = RegExp(r'^[0-9]+([.,][0-9]+)?$');
  
  // Call super.pure to represent an unmodified form input.
  const ExpenseMoneyInput.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const ExpenseMoneyInput.dirty({required String value}) : super.dirty(value);

  String? get errorMessage {
    if(isValid || isPure) return null;
    if(displayError == ExpenseMoneyError.empty) return 'El campo es obligatorio';
    if(displayError == ExpenseMoneyError.format) return 'Número no válido';
    return null;
  }

  // El validador ahora solo se encarga del formato numérico
  @override
  ExpenseMoneyError? validator(String value) {
    if(value.isEmpty || value.trim().isEmpty) return ExpenseMoneyError.empty;
    // Permitimos tanto puntos como comas para los decimales
    if(!expenseRegExp.hasMatch(value.replaceAll(',', '.'))) return ExpenseMoneyError.format;

    return null;
  }
}
