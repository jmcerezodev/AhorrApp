import 'package:intl/intl.dart';

class HumanizeNumbers {
  String number(double input) {
    // Asegurarse de que el número tiene 2 decimales.
    String numberString = input.toStringAsFixed(2);
    
    // Separar la parte entera y decimal.
    List<String> parts = numberString.split('.');
    String integerPart = parts[0]; 
    String decimalPart = parts[1]; 

    // Formatear la parte entera con puntos como separadores de miles solo si es mayor o igual a 1000
    String formattedIntegerPart;
    if (input >= 1000) {
      final NumberFormat formatter = NumberFormat('#,##0', 'es_ES');
      formattedIntegerPart = formatter.format(int.parse(integerPart)).replaceAll(',', '.');
      // Combinar con la parte decimal usando coma si no es cero
      return decimalPart == '00' ? formattedIntegerPart : '$formattedIntegerPart,$decimalPart';
    } else {
      // Para números menores de 1000, solo formatear con punto
      return decimalPart == '00' ? integerPart : '$integerPart.$decimalPart';
    }
  }
}

