import 'package:ahorrapp/core/date/date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Date dateUtils;

  setUp(() {
    dateUtils = Date();
  });

  group('Date Utils - Unit Tests', () {
    test('year() should return a 4-digit year string', () {
      final year = dateUtils.year();
      expect(year.length, 4);
      expect(int.tryParse(year), isNotNull);
    });

    test('monthNumber() should return a value between 1 and 12', () {
      final month = dateUtils.monthNumber();
      expect(month, greaterThanOrEqualTo(1));
      expect(month, lessThanOrEqualTo(12));
    });

    test('monthNames() should return a valid Spanish month name', () {
      final monthName = dateUtils.monthNames();
      final validMonths = [
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ];
      expect(validMonths.contains(monthName), true);
    });

    test('currentDate() should return format d/m/yyyy', () {
      final current = dateUtils.currentDate();
      final parts = current.split('/');
      expect(parts.length, 3);
      expect(int.tryParse(parts[0]), isNotNull); // day
      expect(int.tryParse(parts[1]), isNotNull); // month
      expect(int.tryParse(parts[2]), isNotNull); // year
    });

    test('currentHour() should return formatted time with AM/PM', () {
      final hour = dateUtils.currentHour();
      // Format: hh:mm a
      expect(hour.contains('AM') || hour.contains('PM'), true);
      expect(hour.contains(':'), true);
    });
  });
}
