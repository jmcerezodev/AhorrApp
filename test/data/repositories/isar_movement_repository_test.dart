import 'package:ahorrapp/data/repositories/isar_movement_repository.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLocalDbService extends Mock implements LocalDbService {}

void main() {
  late IsarMovementRepository repository;
  late MockLocalDbService mockLocalDb;

  setUp(() {
    mockLocalDb = MockLocalDbService();
    repository = IsarMovementRepository(localDb: mockLocalDb);
  });

  group('IsarMovementRepository - Blindaje de Datos', () {
    test('getMovementsByMonth debe retornar una lista vacía si no hay datos en Isar', () async {
      // CORREGIDO: Ahora mockeamos ambas tablas para que no devuelvan Null
      when(() => mockLocalDb.getHistoryByMonth(any(), any())).thenAnswer((_) async => []);
      when(() => mockLocalDb.getSavingsByMonth(any(), any())).thenAnswer((_) async => []);
      
      final results = await repository.getMovementsByMonth('user123', 'October', 2023);
      
      expect(results, isEmpty);
      verify(() => mockLocalDb.getHistoryByMonth('October', 2023)).called(1);
      verify(() => mockLocalDb.getSavingsByMonth('October', 2023)).called(1);
    });
  });
}
