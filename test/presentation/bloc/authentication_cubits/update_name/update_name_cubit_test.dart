import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/sync/sync_service.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/presentation/bloc/authentication_cubits/update_name/update_name_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import '../../../../helpers/mock_platform.dart';

class MockLocalDbService extends Mock implements LocalDbService {}
class MockSyncService extends Mock implements SyncService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockLocalDbService mockLocalDb;
  late MockSyncService mockSyncService;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
    setupMockPlatform();
  });

  setUp(() async {
    mockLocalDb = MockLocalDbService();
    mockSyncService = MockSyncService();

    await getIt.reset();

    getIt.registerSingleton<LocalDbService>(mockLocalDb);
    getIt.registerSingleton<SyncService>(mockSyncService);

    SharedPreferences.setMockInitialValues({'name': 'Juan Original'});
    await Preferences.init();
  });

  group('UpdateNameCubit - Blindaje Offline', () {
    test('onSubmit debe actualizar localmente y registrar tarea pendiente', () async {
      final cubit = UpdateNameCubit();
      
      when(() => mockLocalDb.addPendingSync(any(), any(), any()))
          .thenAnswer((_) async => {});
      when(() => mockSyncService.processQueue()).thenAnswer((_) async => {});

      cubit.newNameChanged('Juan Offline');
      
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<UpdateNameState>().having((s) => s.status, 'status', UpdateNameStatus.submitting),
          isA<UpdateNameState>().having((s) => s.status, 'status', UpdateNameStatus.success),
        ]),
      );

      await cubit.onSubmit();
      await expectation;

      expect(Preferences.name, 'Juan Offline');

      verify(() => mockLocalDb.addPendingSync(
        'update_name', 
        'user', 
        {'name': 'Juan Offline'}
      )).called(1);

      verify(() => mockSyncService.processQueue()).called(1);
    });
  });
}
