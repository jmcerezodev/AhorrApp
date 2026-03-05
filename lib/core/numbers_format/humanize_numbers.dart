import 'package:intl/intl.dart';

class HumanizeNumbers {
  String number(double input) {
    // 1. Redondeamos a 2 decimales para evitar ruido de precisión
    final double value = (input * 100).roundToDouble() / 100;

    // 2. Comprobamos si el número tiene decimales. 
    // Usamos una tolerancia muy pequeña para evitar errores de precisión de double.
    // Si la diferencia entre el número y su entero es mayor a 0.001, tiene decimales.
    final bool hasDecimals = (value - value.truncateToDouble()).abs() > 0.001;

    if (!hasDecimals) {
      // Caso sin decimales: 1.000
      return NumberFormat('#,##0', 'es_ES').format(value);
    } else {
      // Caso con decimales: 1.000,42
      // Forzamos 2 decimales siempre que haya alguno
      return NumberFormat('#,##0.00', 'es_ES').format(value);
    }
  }
}
