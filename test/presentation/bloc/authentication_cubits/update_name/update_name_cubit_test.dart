import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/sync/sync_service.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/presentation/bloc/authentication_cubits/update_name/update_name_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';

class MockLocalDbService extends Mock implements LocalDbService {}
class MockSyncService extends Mock implements SyncService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockLocalDbService mockLocalDb;
  late MockSyncService mockSyncService;

  setUpAll(() {
    // Registro de fallbacks para mocktail
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() async {
    mockLocalDb = MockLocalDbService();
    mockSyncService = MockSyncService();

    // Resetear GetIt de forma asíncrona para asegurar limpieza completa
    await getIt.reset();

    getIt.registerSingleton<LocalDbService>(mockLocalDb);
    getIt.registerSingleton<SyncService>(mockSyncService);

    SharedPreferences.setMockInitialValues({'name': 'Juan Original'});
    await Preferences.init();
  });

  group('UpdateNameCubit - Blindaje Offline', () {
    test('onSubmit debe actualizar localmente y registrar tarea pendiente', () async {
      final cubit = UpdateNameCubit();
      
      // Stub para la cola de sincronización
      when(() => mockLocalDb.addPendingSync(any(), any(), any()))
          .thenAnswer((_) async => {});
      when(() => mockSyncService.processQueue()).thenAnswer((_) async => {});

      // Act
      cubit.newNameChanged('Juan Offline');
      
      // Esperamos que emita los estados correspondientes
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<UpdateNameState>().having((s) => s.status, 'status', UpdateNameStatus.submitting),
          isA<UpdateNameState>().having((s) => s.status, 'status', UpdateNameStatus.success),
        ]),
      );

      await cubit.onSubmit();
      await expectation;

      // Assert: Actualización optimista inmediata en Preferencias
      expect(Preferences.name, 'Juan Offline');

      // Assert: Registro en Isar para sincronización futura
      verify(() => mockLocalDb.addPendingSync(
        'update_name', 
        'user', 
        {'name': 'Juan Offline'}
      )).called(1);

      // Assert: Intento de procesar cola inmediatamente
      verify(() => mockSyncService.processQueue()).called(1);
    });
  });
}
