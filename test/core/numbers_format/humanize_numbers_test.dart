import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HumanizeNumbers Tests', () {
    final formatter = HumanizeNumbers();

    test('debe formatear el cero correctamente como entero', () {
      expect(formatter.number(0), '0');
    });

    test('debe formatear números enteros sin decimales innecesarios', () {
      expect(formatter.number(1000), '1.000');
      expect(formatter.number(50), '50');
    });

    test('debe formatear números con decimales usando coma', () {
      expect(formatter.number(1000.50), '1.000,50');
      expect(formatter.number(12.34), '12,34');
    });

    test('debe manejar números negativos', () {
      expect(formatter.number(-100), '-100');
      expect(formatter.number(-10.50), '-10,50');
    });
  });
}
