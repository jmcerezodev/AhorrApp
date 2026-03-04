import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/domain/entities/movement.dart';
import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:ahorrapp/domain/usecases/recurrent_expenses/delete_recurrent_expense_usecase.dart';
import 'package:ahorrapp/domain/usecases/recurrent_expenses/get_recurrent_expenses_usecase.dart';
import 'package:ahorrapp/domain/usecases/recurrent_expenses/save_recurrent_expense_usecase.dart';
import 'package:ahorrapp/domain/usecases/save_movement_usecase.dart';
import 'package:ahorrapp/presentation/bloc/recurrent_expenses_cubit/recurrent_expenses_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockGetRecurrentExpensesUseCase extends Mock implements GetRecurrentExpensesUseCase {}
class MockSaveRecurrentExpenseUseCase extends Mock implements SaveRecurrentExpenseUseCase {}
class MockDeleteRecurrentExpenseUseCase extends Mock implements DeleteRecurrentExpenseUseCase {}
class MockSaveMovementUseCase extends Mock implements SaveMovementUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late RecurrentExpensesCubit cubit;
  late MockGetRecurrentExpensesUseCase mockGet;
  late MockSaveRecurrentExpenseUseCase mockSave;
  late MockDeleteRecurrentExpenseUseCase mockDelete;
  late MockSaveMovementUseCase mockSaveMovement;

  setUpAll(() {
    registerFallbackValue(RecurrentExpense(
      id: '', 
      userId: '', 
      name: '', 
      amount: 0, 
      day: 1, 
      startDate: DateTime.now(),
      position: 0,
      includeInSummary: true,
    ));
    registerFallbackValue(Movement(
      id: '',
      name: '',
      amount: 0,
      type: MovementType.expense,
      isIncome: false,
      date: '',
      hour: '',
      month: '',
      year: 2024,
      createdAt: DateTime.now(),
    ));
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({'uId': 'user123', 'isProratedView': false});
    await Preferences.init();

    mockGet = MockGetRecurrentExpensesUseCase();
    mockSave = MockSaveRecurrentExpenseUseCase();
    mockDelete = MockDeleteRecurrentExpenseUseCase();
    mockSaveMovement = MockSaveMovementUseCase();

    getIt.reset();
    getIt.registerSingleton<GetRecurrentExpensesUseCase>(mockGet);
    getIt.registerSingleton<SaveRecurrentExpenseUseCase>(mockSave);
    getIt.registerSingleton<DeleteRecurrentExpenseUseCase>(mockDelete);
    getIt.registerSingleton<SaveMovementUseCase>(mockSaveMovement);

    cubit = RecurrentExpensesCubit();
  });

  group('RecurrentExpensesCubit - Lógica de Resumen y Exclusiones', () {
    test('Cálculos de totales deben respetar la regla de inclusión (Automáticos vs Manuales)', () async {
      final now = DateTime.now();
      final expenses = [
        // 1. Automático Activo: Debe sumarse siempre (100€)
        RecurrentExpense(id: '1', userId: 'u1', name: 'Auto', amount: 100, day: 5, frequency: RecurrentFrequency.monthly, startDate: now, isActive: true, includeInSummary: false),
        
        // 2. Manual Activo Incluido: Debe sumarse (50€)
        RecurrentExpense(id: '2', userId: 'u1', name: 'Manual IN', amount: 50, day: null, frequency: RecurrentFrequency.monthly, startDate: now, isActive: true, includeInSummary: true),
        
        // 3. Manual Activo Excluido: NO debe sumarse (0€)
        RecurrentExpense(id: '3', userId: 'u1', name: 'Manual OUT', amount: 200, day: null, frequency: RecurrentFrequency.monthly, startDate: now, isActive: true, includeInSummary: false),
        
        // 4. Automático Inactivo: NO debe sumarse (0€)
        RecurrentExpense(id: '4', userId: 'u1', name: 'Auto OFF', amount: 500, day: 10, frequency: RecurrentFrequency.monthly, startDate: now, isActive: false, includeInSummary: true),
      ];
      
      when(() => mockGet(any())).thenAnswer((_) async => expenses);
      await cubit.loadExpenses();

      // Total esperado: 100 (Auto) + 50 (Manual IN) = 150.0
      expect(cubit.state.totalStrictlyMonthly, 150.0);
      expect(cubit.state.totalMonthlyNormalized, 150.0);
    });

    test('Prorrateo debe funcionar con la nueva regla de inclusión', () async {
      final now = DateTime.now();
      final expenses = [
        // Manual Anual Excluido: 1200 / 12 = 100 (pero excluido por ser manual y false)
        RecurrentExpense(id: '1', userId: 'u1', name: 'Anual OUT', amount: 1200, day: null, frequency: RecurrentFrequency.annually, startDate: now, isActive: true, includeInSummary: false),
        
        // Automático Anual: 600 / 12 = 50 (se incluye siempre por ser automático)
        RecurrentExpense(id: '2', userId: 'u1', name: 'Anual AUTO', amount: 600, day: 15, frequency: RecurrentFrequency.annually, startDate: now, isActive: true, includeInSummary: false),
      ];

      when(() => mockGet(any())).thenAnswer((_) async => expenses);
      await cubit.loadExpenses();

      expect(cubit.state.totalMonthlyNormalized, 50.0);
    });
  });

  group('RecurrentExpensesCubit - Lógica Core', () {
    test('Estado inicial debe ser correcto y cargar preferencias', () {
      Preferences.isProratedView = true;
      final newCubit = RecurrentExpensesCubit();
      expect(newCubit.state.showProrated, true);
    });

    test('loadExpenses debe emitir success con lista de gastos', () async {
      final expenses = [RecurrentExpense(
        id: '1', userId: 'u1', name: 'Gasto', amount: 10, day: 1, startDate: DateTime.now(), position: 0
      )];
      when(() => mockGet(any())).thenAnswer((_) async => expenses);

      await cubit.loadExpenses();

      expect(cubit.state.status, RecurrentExpensesStatus.success);
      expect(cubit.state.expenses, expenses);
    });

    test('addOrUpdateExpense debe guardar y recargar la lista', () async {
      when(() => mockSave(any())).thenAnswer((_) async => {});
      when(() => mockGet(any())).thenAnswer((_) async => []);

      await cubit.addOrUpdateExpense(name: 'Netflix', amount: 15.99, day: 10, startDate: DateTime.now());

      verify(() => mockSave(any())).called(1);
      verify(() => mockGet('user123')).called(1);
    });

    test('reorderExpenses debe actualizar posiciones y persistir cambios', () async {
      final e1 = RecurrentExpense(id: '1', userId: 'u1', name: 'A', amount: 10, startDate: DateTime.now(), position: 0);
      final e2 = RecurrentExpense(id: '2', userId: 'u1', name: 'B', amount: 20, startDate: DateTime.now(), position: 1);
      final e3 = RecurrentExpense(id: '3', userId: 'u1', name: 'C', amount: 30, startDate: DateTime.now(), position: 2);
      
      when(() => mockGet(any())).thenAnswer((_) async => [e1, e2, e3]);
      when(() => mockSave(any())).thenAnswer((_) async => {});
      
      await cubit.loadExpenses();
      await cubit.reorderExpenses(0, 3);

      expect(cubit.state.expenses[0].id, '2');
      expect(cubit.state.expenses[1].id, '3');
      expect(cubit.state.expenses[2].id, '1');

      verify(() => mockSave(any())).called(3);
    });

    test('deleteExpense debe eliminar y recargar', () async {
      when(() => mockDelete(any())).thenAnswer((_) async => {});
      when(() => mockGet(any())).thenAnswer((_) async => []);

      await cubit.deleteExpense('123');

      verify(() => mockDelete('123')).called(1);
      verify(() => mockGet('user123')).called(1);
    });

    test('toggleActive debe invertir el estado isActive del gasto', () async {
      final expense = RecurrentExpense(
        id: '1', userId: 'u1', name: 'Gasto', amount: 10, day: 1, isActive: true, startDate: DateTime.now(), position: 0
      );
      when(() => mockSave(any())).thenAnswer((_) async => {});
      when(() => mockGet(any())).thenAnswer((_) async => []);

      await cubit.toggleActive(expense);

      final captured = verify(() => mockSave(captureAny())).captured.first as RecurrentExpense;
      expect(captured.isActive, false);
    });
  });
}
