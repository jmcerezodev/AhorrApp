import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/data/local/models/local_history.dart';
import 'package:ahorrapp/data/local/models/local_saving.dart';
import 'package:ahorrapp/data/local/models/local_recurrent_expense.dart';
import 'package:ahorrapp/data/local/models/local_shopping_list_item.dart';
import 'package:ahorrapp/data/local/models/local_shopping_template.dart';
import 'package:ahorrapp/data/local/models/local_ticket_item.dart';
import 'package:ahorrapp/data/local/models/local_debt_loan.dart';
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
    registerFallbackValue(<LocalHistory>[]);
    registerFallbackValue(<LocalSaving>[]);
    registerFallbackValue(<LocalRecurrentExpense>[]);
    registerFallbackValue(<LocalShoppingItem>[]);
    registerFallbackValue(<LocalShoppingTemplate>[]);
    registerFallbackValue(<LocalTicketItem>[]);
    registerFallbackValue(<LocalDebtLoan>[]);
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

  group('HistoryCubit - Blindaje de Lógica y Sesión', () {
    test('Estado inicial debe ser initial y lista vacía', () {
      expect(historyCubit.state.status, HistoryStatus.initial);
      expect(historyCubit.state.historyList, isEmpty);
    });

    test('prepareForNewLogin debe limpiar Isar y resetear el estado del Cubit', () async {
      when(() => mockLocalDb.clearAll()).thenAnswer((_) async {});
      
      // Forzamos un estado previo sucio (cambiamos de 'descending' a 'ascending')
      historyCubit.listOrder('ascending');
      expect(historyCubit.state.listOrder, 'ascending');
      
      await historyCubit.prepareForNewLogin();
      
      expect(historyCubit.state.status, HistoryStatus.initial);
      expect(historyCubit.state.historyList, isEmpty);
      // Debe volver al valor por defecto real: 'descending'
      expect(historyCubit.state.listOrder, 'descending'); 
      verify(() => mockLocalDb.clearAll()).called(1);
    });

    test('loadHistoryByDate debe forzar sincronización remota si la base de datos está VACÍA', () async {
      // GIVEN: Base de datos vacía (0 registros)
      when(() => mockLocalDb.getTotalCount()).thenAnswer((_) async => 0);
      
      // Mock de sincronización exitosa
      when(() => mockRepo.syncFullData(any(), any())).thenAnswer((_) async => {
        'balance': 0.0,
        'history': [],
        'savings': [],
        'recurrent': [],
        'shopping': [],
        'templates': [],
        'tickets': [],
        'debts': [],
        'savingGoal': 0.0,
      });
      when(() => mockLocalDb.clearAll()).thenAnswer((_) async {});
      when(() => mockLocalDb.saveHistoryItems(any())).thenAnswer((_) async {});
      when(() => mockLocalDb.saveSavingItems(any())).thenAnswer((_) async {});
      when(() => mockLocalDb.saveRecurrentExpenses(any())).thenAnswer((_) async {});
      when(() => mockLocalDb.saveShoppingListItems(any())).thenAnswer((_) async {});
      when(() => mockLocalDb.saveShoppingTemplates(any())).thenAnswer((_) async {});
      when(() => mockLocalDb.saveTicketItems(any())).thenAnswer((_) async {});
      when(() => mockLocalDb.saveDebtLoans(any())).thenAnswer((_) async {});
      when(() => mockLocalDb.saveSavingGoal(any(), any())).thenAnswer((_) async {});
      when(() => mockLocalDb.saveTotalBalance(any(), any())).thenAnswer((_) async {});
      when(() => mockGetMovementsUseCase(any(), any(), any())).thenAnswer((_) async => []);
      when(() => mockTotalMoneyCubit.totalMoney(any())).thenReturn(null);

      // WHEN: Cargamos historia
      await historyCubit.loadHistoryByDate('Enero', 2024);

      // THEN: Se debe haber disparado la sincronización completa
      verify(() => mockRepo.syncFullData(any(), any())).called(1);
      expect(historyCubit.state.status, HistoryStatus.success);
    });

    test('forceBalanceResync debe guardar todos los tipos de datos correctamente', () async {
      final now = DateTime.now().toIso8601String();
      final mockRecurrentDoc = FakeDocument($id: 'rec_123', $createdAt: now, data: {'userId': 'test-user', 'name': 'Test', 'money': 10.0, 'frequency': 'monthly', 'isActive': true, 'startDate': now});
      
      when(() => mockLocalDb.clearAll()).thenAnswer((_) async {});
      when(() => mockRepo.syncFullData(any(), any())).thenAnswer((_) async => {
        'balance': 100.0,
        'history': [],
        'savings': [],
        'recurrent': [mockRecurrentDoc],
        'shopping': [],
        'templates': [],
        'tickets': [],
        'debts': [],
        'savingGoal': 0.0,
      });
      when(() => mockLocalDb.saveHistoryItems(any())).thenAnswer((_) async {});
      when(() => mockLocalDb.saveSavingItems(any())).thenAnswer((_) async {});
      when(() => mockLocalDb.saveRecurrentExpenses(any())).thenAnswer((_) async {});
      when(() => mockLocalDb.saveShoppingListItems(any())).thenAnswer((_) async {});
      when(() => mockLocalDb.saveShoppingTemplates(any())).thenAnswer((_) async {});
      when(() => mockLocalDb.saveTicketItems(any())).thenAnswer((_) async {});
      when(() => mockLocalDb.saveDebtLoans(any())).thenAnswer((_) async {});
      when(() => mockLocalDb.saveSavingGoal(any(), any())).thenAnswer((_) async {});
      when(() => mockLocalDb.saveTotalBalance(any(), any())).thenAnswer((_) async {});
      when(() => mockGetMovementsUseCase(any(), any(), any())).thenAnswer((_) async => []);

      await historyCubit.forceBalanceResync(mockTotalMoneyCubit);

      verify(() => mockLocalDb.saveRecurrentExpenses(any())).called(1);
      expect(historyCubit.state.status, HistoryStatus.success);
    });

   group('Interacciones y UI', () {
      test('listOrder debe actualizar el orden de la lista', () {
        historyCubit.listOrder('ascending');
        expect(historyCubit.state.listOrder, 'ascending');
      });

      test('toggleIncomes debe invertir el flag de ingresos', () {
        final initial = historyCubit.state.showIncomes;
        historyCubit.toggleIncomes(!initial);
        expect(historyCubit.state.showIncomes, !initial);
      });
    });
  });
}
