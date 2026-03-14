import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es_ES', null);
  });

  group('HumanizeNumbers - Pruebas de Formato Condicional', () {
    final formatter = HumanizeNumbers();

    test('Debe ocultar decimales si son .00 (ej: 1.000)', () {
      expect(formatter.number(1000.00), '1.000');
      expect(formatter.number(50.0), '50');
      expect(formatter.number(0.0), '0');
    });

    test('Debe mostrar hasta 2 decimales si son distintos de cero (ej: 1.000,02)', () {
      expect(formatter.number(1000.02), '1.000,02');
      expect(formatter.number(1000.50), '1.000,5');
      expect(formatter.number(12.34), '12,34');
    });

    test('Debe manejar errores de precisión de punto flotante de Dart', () {
      // 0.1 + 0.2 es 0.30000000000000004
      expect(formatter.number(0.1 + 0.2), '0,3'); 
    });

    test('Debe funcionar con números negativos', () {
      expect(formatter.number(-100.00), '-100');
      expect(formatter.number(-10.50), '-10,5');
    });

    test('Debe mostrar puntos si el modo privacidad está activo', () {
      expect(formatter.number(100.00, isPrivacyModeActive: true), '••••');
    });
  });
}
