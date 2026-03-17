import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HumanizeNumbers humanize;

  setUp(() {
    humanize = HumanizeNumbers();
  });

  group('HumanizeNumbers - format', () {
    test('should format integers without decimals', () {
      expect(humanize.format(100), '100');
      expect(humanize.format(1200), '1.200');
    });

    test('should format decimals with comma (es_ES locale behavior)', () {
      expect(humanize.format(100.5), '100,5');
      expect(humanize.format(100.56), '100,56');
    });

    test('should limit decimals to 2', () {
      expect(humanize.format(100.567), '100,57');
    });

    test('should return dots when privacy mode is active', () {
      expect(humanize.format(100.5, isPrivacyModeActive: true), '••••');
    });
  });

  group('HumanizeNumbers - parse', () {
    test('should parse simple integers', () {
      expect(humanize.parse('100'), 100.0);
    });

    test('should parse simple decimals with dot', () {
      expect(humanize.parse('1200.5'), 1200.5);
    });

    test('should parse simple decimals with comma', () {
      expect(humanize.parse('1200,5'), 1200.5);
    });

    test('should parse European format (dots for thousands, comma for decimals)', () {
      expect(humanize.parse('1.200,50'), 1200.5);
      expect(humanize.parse('1.200.300,75'), 1200300.75);
    });

    test('should parse American format (commas for thousands, dot for decimals)', () {
      expect(humanize.parse('1,200.50'), 1200.5);
      expect(humanize.parse('1,200,300.75'), 1200300.75);
    });

    test('should return 0.0 for empty or invalid input', () {
      expect(humanize.parse(''), 0.0);
      expect(humanize.parse('abc'), 0.0);
    });

    test('should handle spaces and non-breaking spaces', () {
      expect(humanize.parse('1 200,50'), 1200.5);
      expect(humanize.parse('1\u00A0200,50'), 1200.5);
    });
  });
}
