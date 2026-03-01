import 'package:intl/intl.dart';

class HumanizeNumbers {
  String number(double input) {
    // 1. Si el número es exactamente 0, mostramos 0,00
    if (input == 0) {
      return NumberFormat.currency(
        locale: 'es_ES',
        symbol: '',
        decimalDigits: 2,
      ).format(0).trim();
    }

    // 2. Comprobamos si es un número entero (sin decimales significativos)
    if (input == input.truncateToDouble()) {
      return NumberFormat.currency(
        locale: 'es_ES',
        symbol: '',
        decimalDigits: 0,
      ).format(input).trim();
    } else {
      // 3. Si tiene decimales, mostramos 2 dígitos
      return NumberFormat.currency(
        locale: 'es_ES',
        symbol: '',
        decimalDigits: 2,
      ).format(input).trim();
    }
  }
}
