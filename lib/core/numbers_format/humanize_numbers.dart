import 'package:intl/intl.dart';

class HumanizeNumbers {
  /// Formatea un número para mostrarlo al usuario (ej. 100.0 -> '100', 100.556 -> '100,56').
  String format(double number, {bool isPrivacyModeActive = false}) {
    if (isPrivacyModeActive) {
      return '••••';
    }

    final formatter = NumberFormat.decimalPattern('es_ES')
      ..minimumFractionDigits = 0
      ..maximumFractionDigits = 2;

    return formatter.format(number).trim();
  }

  /// Alias de format para mantener compatibilidad mientras se migra
  String number(double number, {bool isPrivacyModeActive = false}) {
    return format(number, isPrivacyModeActive: isPrivacyModeActive);
  }

  /// Convierte cualquier texto del usuario en un double válido.
  /// Maneja puntos de miles, comas decimales e inteligencia para formatos mixtos.
  double parse(String input) {
    if (input.trim().isEmpty) return 0.0;

    // 1. Limpiamos espacios y caracteres no numéricos excepto punto y coma
    String sanitized = input.trim().replaceAll(' ', '').replaceAll('\u00A0', '');
    
    // 2. Detectamos si el formato usa el punto como miles (estilo europeo 1.200,50)
    // o el punto como decimal (estilo americano 1,200.50)
    
    final int lastComma = sanitized.lastIndexOf(',');
    final int lastDot = sanitized.lastIndexOf('.');

    if (lastComma > lastDot) {
      // Formato europeo: 1.200,50 -> Eliminamos puntos y cambiamos coma por punto
      sanitized = sanitized.replaceAll('.', '').replaceAll(',', '.');
    } else if (lastDot > lastComma) {
      // Formato americano: 1,200.50 -> Eliminamos comas
      sanitized = sanitized.replaceAll(',', '');
    } else if (lastComma != -1) {
      // Solo hay coma: 1200,50 -> Cambiamos por punto
      sanitized = sanitized.replaceAll(',', '.');
    }

    return double.tryParse(sanitized) ?? 0.0;
  }
}
