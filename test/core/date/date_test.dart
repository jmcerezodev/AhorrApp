import 'package:ahorrapp/core/date/date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Date Utility Tests', () {
    final dateUtil = Date();

    test('currentDate debe devolver un formato de fecha (D/M/YYYY)', () {
      final date = dateUtil.currentDate();
      // El formato es d/m/yyyy sin ceros a la izquierda obligatorios
      final regExp = RegExp(r'^\d{1,2}/\d{1,2}/\d{4}$');
      expect(regExp.hasMatch(date), true);
    });

    test('currentHour debe devolver un formato de hora (hh:mm AM/PM)', () {
      final hour = dateUtil.currentHour();
      // El formato real es 12h con AM/PM (ej: 01:30 PM)
      final regExp = RegExp(r'^\d{2}:\d{2} (AM|PM)$');
      expect(regExp.hasMatch(hour), true);
    });

    test('monthNames debe devolver un nombre de mes válido en español', () {
      final month = dateUtil.monthNames();
      final validMonths = [
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ];
      expect(validMonths.contains(month), true);
    });

    test('year debe devolver el año actual en 4 dígitos', () {
      final year = dateUtil.year();
      expect(year.length, 4);
      expect(int.tryParse(year), isNotNull);
    });
  });
}
