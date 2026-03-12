import 'dart:io';
import 'package:ahorrapp/data/local/models/local_history.dart';
import 'package:ahorrapp/data/local/models/local_saving.dart';
import 'package:ahorrapp/data/repositories/isar_movement_repository.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;

class MockLocalDbService extends Mock implements LocalDbService {}

void main() {
  late IsarMovementRepository repository;
  late MockLocalDbService mockLocalDb;
  late Isar isar;
  late String tempPath;

  setUpAll(() async {
    tempPath = p.join(Directory.current.path, 'test_db_movements');
    final dir = Directory(tempPath);
    if (dir.existsSync()) {
      try {
        dir.deleteSync(recursive: true);
      } catch (e) {
        // Ignorar si el archivo está bloqueado temporalmente por otro proceso
      }
    }
    if (!dir.existsSync()) dir.createSync(recursive: true);

    await Isar.initializeIsarCore(download: true);
    isar = await Isar.open(
      [LocalHistorySchema, LocalSavingSchema],
      directory: tempPath,
    );
  });

  tearDownAll(() async {
    await isar.close();
  });

  setUp(() {
    mockLocalDb = MockLocalDbService();
    when(() => mockLocalDb.isar).thenReturn(isar);
    repository = IsarMovementRepository(localDb: mockLocalDb);
    isar.writeTxnSync(() => isar.clearSync());
  });

  group('IsarMovementRepository - Pruebas con Isar Real', () {
    test('getMovementsByMonth debe retornar datos reales de la base de datos', () async {
      final history = LocalHistory()
        ..appwriteId = 'h1'
        ..name = 'Sueldo'
        ..money = 2000
        ..isIncome = true
        ..type = 'income'
        ..currentDate = '2023-10-01'
        ..currentHour = '10:00'
        ..month = 'October'
        ..year = 2023
        ..createdAt = DateTime.now()
        ..isRecurrent = false
        ..category = 'Salario'
        ..isTransferred = false;

      final saving = LocalSaving()
        ..appwriteId = 's1'
        ..userId = 'user123'
        ..money = 500
        ..month = 'October'
        ..year = 2023
        ..description = 'Ahorro'
        ..createdAt = DateTime.now();

      await isar.writeTxn(() async {
        await isar.localHistorys.put(history);
        await isar.localSavings.put(saving);
      });

      when(() => mockLocalDb.getHistoryByMonth('October', 2023)).thenAnswer((_) async {
        return await isar.localHistorys.filter().monthEqualTo('October').yearEqualTo(2023).findAll();
      });
      when(() => mockLocalDb.getSavingsByMonth('October', 2023)).thenAnswer((_) async {
        return await isar.localSavings.filter().monthEqualTo('October').yearEqualTo(2023).findAll();
      });
      
      final results = await repository.getMovementsByMonth('user123', 'October', 2023);
      
      expect(results, hasLength(2));
      expect(results.any((m) => m.name == 'Sueldo'), isTrue);
      expect(results.any((m) => m.name == 'Ahorro'), isTrue);
    });

    test('detachTicketFromMovements debe limpiar el ticketId de los registros', () async {
      final historyWithTicket = LocalHistory()
        ..appwriteId = 'h2'
        ..name = 'Compra'
        ..money = 50
        ..isIncome = false
        ..type = 'expense'
        ..currentDate = '2023-10-02'
        ..currentHour = '12:00'
        ..month = 'October'
        ..year = 2023
        ..createdAt = DateTime.now()
        ..isRecurrent = false
        ..category = 'Súper'
        ..isTransferred = true
        ..ticketId = 'ticket-123';

      await isar.writeTxn(() async {
        await isar.localHistorys.put(historyWithTicket);
      });

      await repository.detachTicketFromMovements('ticket-123');

      final updated = await isar.localHistorys.filter().appwriteIdEqualTo('h2').findFirst();
      expect(updated?.ticketId, isNull);
    });
  });
}
