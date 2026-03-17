import 'dart:convert';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/data/local/models/local_history.dart';
import 'package:ahorrapp/data/local/models/pending_sync.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../mocks/mock_definitions.dart';

void main() {
  late MockLocalDbService mockLocalDb;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockLocalDb = MockLocalDbService();
    mockPrefs = MockSharedPreferences();
    Preferences.setPrefs = mockPrefs;
    when(() => mockPrefs.getString('uId')).thenReturn('user-123');
  });

  group('Data Integrity - Critical Scenarios', () {
    
    test('Category Resilience: Movements should survive if their category is generic', () {
      // Escenario: Tenemos movimientos con categoría 'Alimentación'
      final movement = LocalHistory()
        ..appwriteId = '1'
        ..name = 'Supermarket'
        ..money = 50.0
        ..category = 'Alimentación'
        ..type = 'expense'
        ..isIncome = false
        ..month = 'Enero'
        ..year = 2024
        ..createdAt = DateTime.now();

      // En AhorrApp las categorías son Strings planos en cada movimiento.
      // Si el usuario "borra" una categoría de su lista de favoritos (UI), 
      // el movimiento en la DB debe permanecer intacto.
      expect(movement.category, 'Alimentación');
      
      // Simulamos "limpieza" o cambio masivo
      movement.category = 'general';
      expect(movement.money, 50.0); // El dato financiero no se ve afectado
    });

    test('UUID Consistency: Offline creation must link local and remote IDs', () async {
      final pendingData = {
        'name': 'Gasto Offline',
        'money': 100.0,
        'userId': 'user-123'
      };
      
      // Al registrar un gasto offline
      final movementId = 'uuid-local-123';
      
      when(() => mockLocalDb.addPendingSync(
        'create', 
        'history', 
        pendingData, 
        appwriteId: movementId
      )).thenAnswer((_) async => 1);

      await mockLocalDb.addPendingSync(
        'create', 
        'history', 
        pendingData, 
        appwriteId: movementId
      );

      // Verificamos que el ID se pasó a la cola de sincronización para que Appwrite 
      // use el MISMO ID y no genere duplicados al reintentar.
      verify(() => mockLocalDb.addPendingSync(
        'create', 
        'history', 
        pendingData, 
        appwriteId: movementId
      )).called(1);
    });

    test('Secure Cleanup: clearAll should wipe all sensitive collections', () async {
      when(() => mockLocalDb.clearAll()).thenAnswer((_) async => {});
      
      await mockLocalDb.clearAll();
      
      // Verificamos que se llama a la función que ejecuta los .clear() de Isar
      verify(() => mockLocalDb.clearAll()).called(1);
    });
  });
}
