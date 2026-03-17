import 'package:ahorrapp/core/filter_lists/filter_lists.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FilterLists filterLists;

  setUp(() {
    filterLists = FilterLists();
  });

  final List<Map<String, dynamic>> mockHistory = [
    {
      'name': 'Income 1',
      'money': 1000.0,
      'type': 'income',
      'month': 'Enero',
      'year': 2024,
    },
    {
      'name': 'Expense 1',
      'money': 200.0,
      'type': 'expense',
      'month': 'Enero',
      'year': 2024,
    },
    {
      'name': 'Saving 1',
      'money': 500.0,
      'type': 'saving',
      'month': 'Enero',
      'year': 2024,
    },
    {
      'name': 'Income 2',
      'money': 1000.0,
      'type': 'income',
      'month': 'Febrero',
      'year': 2024,
    },
    {
      'name': 'Income Old',
      'money': 1000.0,
      'type': 'income',
      'month': 'Enero',
      'year': 2023,
    },
  ];

  group('FilterLists - Year Finding', () {
    test('findMaxYear should return the latest year', () {
      expect(filterLists.findMaxYear(mockHistory), 2024);
    });

    test('findMinYear should return the earliest year', () {
      expect(filterLists.findMinYear(mockHistory), 2023);
    });
  });

  group('FilterLists - Monthly Aggregations', () {
    test('calculateTotalIncomes should only sum incomes for the given year per month', () {
      final results = filterLists.calculateTotalIncomes(mockHistory, 2024);
      expect(results[0], 1000.0); // Enero 2024
      expect(results[1], 1000.0); // Febrero 2024
      expect(results.skip(2).every((val) => val == 0.0), true);
    });

    test('calculateTotalExpenses should only sum expenses for the given year per month', () {
      final results = filterLists.calculateTotalExpenses(mockHistory, 2024);
      expect(results[0], 200.0); // Enero 2024
      expect(results.skip(1).every((val) => val == 0.0), true);
    });

    test('calculateTotalSavings should only sum savings for the given year per month', () {
      final results = filterLists.calculateTotalSavings(mockHistory, 2024);
      expect(results[0], 500.0); // Enero 2024
      expect(results.skip(1).every((val) => val == 0.0), true);
    });
  });
}
