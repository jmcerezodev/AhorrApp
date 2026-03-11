import 'dart:io';
import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/data/local/models/local_recurrent_expense.dart';
import 'package:ahorrapp/data/repositories/isar_recurrent_expense_repository.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;

class MockLocalDbService extends Mock implements LocalDbService {}

void main() {
  late IsarRecurrentExpenseRepository repository;
  late MockLocalDbService mockLocalDb;
  late Isar isar;
  late String tempPath;

  setUpAll(() async {
    tempPath = p.join(Directory.current.path, 'test_db_recurrent');
    final dir = Directory(tempPath);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
    dir.createSync(recursive: true);

    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open(
      [LocalRecurrentExpenseSchema],
      directory: tempPath,
    );
  });

  tearDownAll(() async {
    await isar.close(deleteFromDisk: true);
  });

  setUp(() {
    mockLocalDb = MockLocalDbService();
    when(() => mockLocalDb.isar).thenReturn(isar);
    
    getIt.reset();
    getIt.registerSingleton<LocalDbService>(mockLocalDb);
    
    repository = IsarRecurrentExpenseRepository();
    isar.writeTxnSync(() => isar.clearSync());
  });

  group('IsarRecurrentExpenseRepository - Pruebas de Integridad', () {
    test('saveRecurrentExpense debe insertar correctamente', () async {
      final expense = RecurrentExpense(
        id: 'rec_1',
        userId: 'u1',
        name: 'Netflix',
        amount: 12.99,
        category: 'entretenimiento',
        isActive: true,
        frequency: RecurrentFrequency.monthly,
        startDate: DateTime.now(),
        position: 0,
        includeInSummary: true,
        isIncome: false,
      );

      when(() => mockLocalDb.saveRecurrentExpenses(any())).thenAnswer((_) async {});

      await repository.saveRecurrentExpense(expense);

      verify(() => mockLocalDb.saveRecurrentExpenses(any())).called(1);
    });

    test('getRecurrentExpenses debe retornar la lista ordenada', () async {
      final e1 = LocalRecurrentExpense()
        ..appwriteId = 'id1'
        ..userId = 'u1'
        ..name = 'A'
        ..money = 10
        ..category = 'cat'
        ..isActive = true
        ..frequency = LocalRecurrentFrequency.monthly
        ..startDate = DateTime.now()
        ..createdAt = DateTime.now()
        ..position = 1
        ..includeInSummary = true
        ..isIncome = false;

      when(() => mockLocalDb.getRecurrentExpenses('u1')).thenAnswer((_) async => [e1]);

      final results = await repository.getRecurrentExpenses('u1');

      expect(results, hasLength(1));
      verify(() => mockLocalDb.getRecurrentExpenses('u1')).called(1);
    });
  });
}
