import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/data/local/models/local_history.dart';
import 'package:ahorrapp/data/local/models/local_saving.dart';
import 'package:ahorrapp/data/local/models/local_recurrent_expense.dart';
import 'package:ahorrapp/domain/usecases/get_movements_usecase.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/bloc/history_cubit/history_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Clase auxiliar para simular Documentos de Appwrite
class FakeDocument {
  final String $id;
  final String $createdAt;
  final Map<String, dynamic> data;
  FakeDocument({required this.$id, required this.$createdAt, required this.data});
}

class MockGetMovementsUseCase extends Mock implements GetMovementsUseCase {}
class MockAppwriteRepository extends Mock implements AppwriteRepository {}
class MockLocalDbService extends Mock implements LocalDbService {}
class MockTotalMoneyCubit extends Mock implements TotalMoneyCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late HistoryCubit historyCubit;
  late MockGetMovementsUseCase mockGetMovementsUseCase;
  late MockAppwriteRepository mockRepo;
  late MockLocalDbService mockLocalDb;
  late MockTotalMoneyCubit mockTotalMoneyCubit;

  setUpAll(() {
    // Registrar fallbacks específicos para evitar errores de mocktail con listas
    registerFallbackValue(<LocalHistory>[]);
    registerFallbackValue(<LocalSaving>[]);
    registerFallbackValue(<LocalRecurrentExpense>[]);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({'uId': 'test-user'});
    await Preferences.init();

    mockGetMovementsUseCase = MockGetMovementsUseCase();
    mockRepo = MockAppwriteRepository();
    mockLocalDb = MockLocalDbService();
    mockTotalMoneyCubit = MockTotalMoneyCubit();

    getIt.reset();
    getIt.registerSingleton<GetMovementsUseCase>(mockGetMovementsUseCase);
    getIt.registerSingleton<AppwriteRepository>(mockRepo);
    getIt.registerSingleton<LocalDbService>(mockLocalDb);

    historyCubit = HistoryCubit(totalMoneyCubit: mockTotalMoneyCubit);
  });

  group('HistoryCubit - Blindaje de Lógica', () {
    test('Estado inicial debe ser initial y lista vacía', () {
      expect(historyCubit.state.status, HistoryStatus.initial);
      expect(historyCubit.state.historyList, isEmpty);
    });

    test('toggleFilterPanel debe cambiar el estado del filtro', () {
      expect(historyCubit.state.isFilterOpen, false);
      historyCubit.toggleFilterPanel();
      expect(historyCubit.state.isFilterOpen, true);
    });

    test('loadHistoryByDate debe fallar si no hay datos en Isar ni Appwrite', () async {
      when(() => mockLocalDb.getTotalCount()).thenAnswer((_) async => 0);
      when(() => mockRepo.syncFullData(any(), any())).thenThrow(Exception('No data'));

      await historyCubit.loadHistoryByDate('October', 2023);
      
      expect(historyCubit.state.status, HistoryStatus.failure);
    });

    test('forceBalanceResync debe guardar los gastos recurrentes correctamente', () async {
      // GIVEN: Simulación de datos de Appwrite incluyendo recurrentes
      final now = DateTime.now().toIso8601String();
      final mockRecurrentDoc = FakeDocument(
        $id: 'rec_123',
        $createdAt: now,
        data: {
          'userId': 'test-user',
          'name': 'Suscripción Gym',
          'money': 29.99,
          'frequency': 'monthly',
          'isActive': true,
          'startDate': now,
        },
      );

      when(() => mockLocalDb.clearAll()).thenAnswer((_) async {});
      when(() => mockRepo.syncFullData(any(), any())).thenAnswer((_) async => {
        'balance': 1500.0,
        'history': [],
        'savings': [],
        'recurrent': [mockRecurrentDoc],
        'savingGoal': 500.0,
      });
      when(() => mockLocalDb.saveHistoryItems(any())).thenAnswer((_) async {});
      when(() => mockLocalDb.saveSavingItems(any())).thenAnswer((_) async {});
      when(() => mockLocalDb.saveRecurrentExpenses(any())).thenAnswer((_) async {});
      when(() => mockLocalDb.saveSavingGoal(any(), any())).thenAnswer((_) async {});
      when(() => mockLocalDb.saveTotalBalance(any(), any())).thenAnswer((_) async {});
      when(() => mockGetMovementsUseCase(any(), any(), any())).thenAnswer((_) async => []);

      // WHEN: Ejecutamos la resincronización forzada
      await historyCubit.forceBalanceResync(mockTotalMoneyCubit);

      // THEN: Verificamos que se llamó a guardar los recurrentes
      verify(() => mockLocalDb.saveRecurrentExpenses(any())).called(1);
      expect(historyCubit.state.status, HistoryStatus.success);
    });
  });
}
