import 'package:intl/intl.dart';

class HumanizeNumbers {
  String number(double input) {
    // 1. Redondeamos a 2 decimales para eliminar imprecisiones de punto flotante
    final double value = double.parse(input.toStringAsFixed(2));

    // 2. Si el número es igual a su parte entera, lo tratamos como entero
    if (value == value.truncateToDouble()) {
      // Usamos el patrón decimal de España (ej. 1.002)
      return NumberFormat.decimalPattern('es_ES').format(value);
    } else {
      // 3. Si tiene decimales, usamos el formato moneda con 2 dígitos (ej. 1.002,50)
      return NumberFormat.currency(
        locale: 'es_ES',
        symbol: '',
        decimalDigits: 2,
      ).format(value).trim();
    }
  }
}
