import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/domain/usecases/save_movement_usecase.dart';
import 'package:ahorrapp/presentation/bloc/savings_cubit/savings_cubit.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';

class MockAppwriteRepository extends Mock implements AppwriteRepository {}
class MockLocalDbService extends Mock implements LocalDbService {}
class MockSaveMovementUseCase extends Mock implements SaveMovementUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SavingsCubit savingsCubit;
  late MockAppwriteRepository mockRepo;
  late MockLocalDbService mockLocalDb;
  late MockSaveMovementUseCase mockUseCase;

  setUpAll(() {
    // Mock de canales para evitar errores de plugins
    const MethodChannel pathChannel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, (MethodCall methodCall) async => '.');
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({'uId': 'test-user'});
    await Preferences.init();

    mockRepo = MockAppwriteRepository();
    mockLocalDb = MockLocalDbService();
    mockUseCase = MockSaveMovementUseCase();

    getIt.reset();
    getIt.registerSingleton<AppwriteRepository>(mockRepo);
    getIt.registerSingleton<LocalDbService>(mockLocalDb);
    getIt.registerSingleton<SaveMovementUseCase>(mockUseCase);

    when(() => mockLocalDb.getSavingGoal(any())).thenAnswer((_) async => 500.0);
    when(() => mockLocalDb.calculateTotalSavings(any())).thenAnswer((_) async => 100.0);

    savingsCubit = SavingsCubit();
    // Esperamos a que la carga inicial termine para que el stream esté limpio
    await Future.delayed(Duration.zero);
  });

  group('SavingsCubit - Limpieza de Lógica', () {
    test('setGoal debe pasar por loading y llegar a success', () async {
      when(() => mockLocalDb.saveSavingGoal(any(), any())).thenAnswer((_) async => {});
      when(() => mockRepo.updatePrefs(any())).thenAnswer((_) async => {});

      final expectation = [
        isA<SavingsCubitState>().having((s) => s.status, 'status', SavingsStatus.loading),
        isA<SavingsCubitState>().having((s) => s.status, 'status', SavingsStatus.success),
      ];

      expectLater(savingsCubit.stream, emitsInOrder(expectation));
      await savingsCubit.setGoal(1000.0);
    });

    test('setGoal debe emitir failure si falla la red', () async {
      when(() => mockLocalDb.saveSavingGoal(any(), any())).thenAnswer((_) async => {});
      when(() => mockRepo.updatePrefs(any())).thenThrow(Exception('Network Error'));

      final expectation = [
        isA<SavingsCubitState>().having((s) => s.status, 'status', SavingsStatus.loading),
        isA<SavingsCubitState>().having((s) => s.status, 'status', SavingsStatus.failure),
      ];

      expectLater(savingsCubit.stream, emitsInOrder(expectation));
      await savingsCubit.setGoal(1000.0);
    });
  });
}
