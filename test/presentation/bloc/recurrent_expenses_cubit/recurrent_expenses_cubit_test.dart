import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/domain/entities/movement.dart';
import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:ahorrapp/domain/usecases/recurrent_expenses/delete_recurrent_expense_usecase.dart';
import 'package:ahorrapp/domain/usecases/recurrent_expenses/get_recurrent_expenses_usecase.dart';
import 'package:ahorrapp/domain/usecases/recurrent_expenses/save_recurrent_expense_usecase.dart';
import 'package:ahorrapp/domain/usecases/save_movement_usecase.dart';
import 'package:ahorrapp/presentation/bloc/debts_loans_cubit/debts_loans_cubit.dart';
import 'package:ahorrapp/presentation/bloc/recurrent_expenses_cubit/recurrent_expenses_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockGetRecurrentExpensesUseCase extends Mock implements GetRecurrentExpensesUseCase {}
class MockSaveRecurrentExpenseUseCase extends Mock implements SaveRecurrentExpenseUseCase {}
class MockDeleteRecurrentExpenseUseCase extends Mock implements DeleteRecurrentExpenseUseCase {}
class MockSaveMovementUseCase extends Mock implements SaveMovementUseCase {}
class MockDebtsLoansCubit extends Mock implements DebtsLoansCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late RecurrentExpensesCubit cubit;
  late MockGetRecurrentExpensesUseCase mockGet;
  late MockSaveRecurrentExpenseUseCase mockSave;
  late MockDeleteRecurrentExpenseUseCase mockDelete;
  late MockSaveMovementUseCase mockSaveMovement;
  late MockDebtsLoansCubit mockDebtsCubit;

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
    mockDebtsCubit = MockDebtsLoansCubit();

    getIt.reset();
    getIt.registerSingleton<GetRecurrentExpensesUseCase>(mockGet);
    getIt.registerSingleton<SaveRecurrentExpenseUseCase>(mockSave);
    getIt.registerSingleton<DeleteRecurrentExpenseUseCase>(mockDelete);
    getIt.registerSingleton<SaveMovementUseCase>(mockSaveMovement);

    cubit = RecurrentExpensesCubit();
  });

  group('RecurrentExpensesCubit - Sincronización con Deudas', () {
    test('applyExpenseManually debe actualizar deuda vinculada si existe', () async {
      final expense = RecurrentExpense(id: 'exp1', userId: 'u1', name: 'Gasto', amount: 50, day: 1, startDate: DateTime.now(), position: 0);
      final debt = DebtLoan(id: 'debt1', userId: 'u1', name: 'Deuda', person: 'Juan', totalAmount: 500, paidAmount: 0, type: DebtLoanType.debt, recurrentExpenseId: 'exp1');
      
      when(() => mockSaveMovement(any())).thenAnswer((_) async => {});
      when(() => mockDebtsCubit.state).thenReturn(DebtsLoansState(debtsLoans: [debt]));
      when(() => mockDebtsCubit.addPayment(any(), any(), addToHistory: false)).thenAnswer((_) async => {});

      await cubit.applyExpenseManually(expense, debtsCubit: mockDebtsCubit);

      verify(() => mockSaveMovement(any())).called(1);
      verify(() => mockDebtsCubit.addPayment('debt1', 50, addToHistory: false)).called(1);
    });

    test('deleteExpense con deleteDebt true debe llamar a deleteByRecurrentId en deudas', () async {
      when(() => mockDelete(any())).thenAnswer((_) async => {});
      when(() => mockGet(any())).thenAnswer((_) async => []);
      when(() => mockDebtsCubit.deleteByRecurrentId(any())).thenAnswer((_) async => {});

      await cubit.deleteExpense('exp1', debtsCubit: mockDebtsCubit, deleteDebt: true);

      verify(() => mockDelete('exp1')).called(1);
      verify(() => mockDebtsCubit.deleteByRecurrentId('exp1')).called(1);
    });

    test('deleteExpense con deleteDebt false debe llamar a clearRecurrentReference en deudas', () async {
      when(() => mockDelete(any())).thenAnswer((_) async => {});
      when(() => mockGet(any())).thenAnswer((_) async => []);
      when(() => mockDebtsCubit.clearRecurrentReference(any())).thenAnswer((_) async => {});

      await cubit.deleteExpense('exp1', debtsCubit: mockDebtsCubit, deleteDebt: false);

      verify(() => mockDelete('exp1')).called(1);
      verify(() => mockDebtsCubit.clearRecurrentReference('exp1')).called(1);
    });
  });

  group('RecurrentExpensesCubit - Lógica de Posicionamiento y Resumen', () {
    test('reorderExpenses debe actualizar posiciones y persistir cambios', () async {
      final e1 = RecurrentExpense(id: '1', userId: 'u1', name: 'A', amount: 10, startDate: DateTime.now(), position: 0);
      final e2 = RecurrentExpense(id: '2', userId: 'u1', name: 'B', amount: 20, startDate: DateTime.now(), position: 1);
      final e3 = RecurrentExpense(id: '3', userId: 'u1', name: 'C', amount: 30, startDate: DateTime.now(), position: 2);
      
      when(() => mockGet(any())).thenAnswer((_) async => [e1, e2, e3]);
      when(() => mockSave(any())).thenAnswer((_) async => {});
      
      await cubit.loadExpenses();
      // Movemos el primero al final
      await cubit.reorderExpenses(0, 3);

      // Verificamos que las posiciones en el estado se han actualizado
      expect(cubit.state.expenses[0].id, '2');
      expect(cubit.state.expenses[0].position, 0);
      expect(cubit.state.expenses[1].id, '3');
      expect(cubit.state.expenses[1].position, 1);
      expect(cubit.state.expenses[2].id, '1');
      expect(cubit.state.expenses[2].position, 2);

      // Verificamos que se ha llamado a guardar para cada uno con su nueva posición
      final captured = verify(() => mockSave(captureAny())).captured;
      expect(captured.length, 3);
      expect((captured[0] as RecurrentExpense).position, 0);
      expect((captured[1] as RecurrentExpense).position, 1);
      expect((captured[2] as RecurrentExpense).position, 2);
    });

    test('addOrUpdateExpense debe mantener position e includeInSummary', () async {
      final existing = RecurrentExpense(
        id: '1', userId: 'u1', name: 'Netflix', amount: 15, startDate: DateTime.now(), position: 5, includeInSummary: false
      );
      
      when(() => mockGet(any())).thenAnswer((_) async => [existing]);
      when(() => mockSave(any())).thenAnswer((_) async => {});
      
      await cubit.loadExpenses();
      
      // Actualizamos solo el nombre
      await cubit.addOrUpdateExpense(id: '1', name: 'Netflix 4K', amount: 15);

      final captured = verify(() => mockSave(captureAny())).captured.first as RecurrentExpense;
      expect(captured.name, 'Netflix 4K');
      expect(captured.position, 5); // Debe mantener la posición original
      expect(captured.includeInSummary, false); // Debe mantener el flag de resumen
    });
  });

  group('RecurrentExpensesCubit - Lógica de Filtrado', () {
    test('toggleFilterPanel debe alternar la visibilidad del panel', () {
      expect(cubit.state.isFilterOpen, false);
      cubit.toggleFilterPanel();
      expect(cubit.state.isFilterOpen, true);
      cubit.toggleFilterPanel();
      expect(cubit.state.isFilterOpen, false);
    });

    test('Filtros de tipo deben actualizar el estado correctamente', () {
      expect(cubit.state.showAutomatic, true);
      expect(cubit.state.showManual, true);

      cubit.toggleAutomaticFilter(false);
      expect(cubit.state.showAutomatic, false);

      cubit.toggleManualFilter(false);
      expect(cubit.state.showManual, false);
    });

    test('toggleCategoryFilter debe añadir y eliminar categorías correctamente', () {
      expect(cubit.state.selectedCategories, isEmpty);

      cubit.toggleCategoryFilter('hogar');
      expect(cubit.state.selectedCategories, contains('hogar'));

      cubit.toggleCategoryFilter('ocio');
      expect(cubit.state.selectedCategories, containsAll(['hogar', 'ocio']));

      cubit.toggleCategoryFilter('hogar');
      expect(cubit.state.selectedCategories, isNot(contains('hogar')));
      expect(cubit.state.selectedCategories, contains('ocio'));
    });
  });

  group('RecurrentExpensesCubit - Lógica de Resumen y Exclusiones', () {
    test('Cálculos de totales deben respetar la regla de inclusión (Automáticos vs Manuales)', () async {
      final now = DateTime.now();
      final expenses = [
        RecurrentExpense(id: '1', userId: 'u1', name: 'Auto', amount: 100, day: 5, frequency: RecurrentFrequency.monthly, startDate: now, isActive: true, includeInSummary: false),
        RecurrentExpense(id: '2', userId: 'u1', name: 'Manual IN', amount: 50, day: null, frequency: RecurrentFrequency.monthly, startDate: now, isActive: true, includeInSummary: true),
        RecurrentExpense(id: '3', userId: 'u1', name: 'Manual OUT', amount: 200, day: null, frequency: RecurrentFrequency.monthly, startDate: now, isActive: true, includeInSummary: false),
        RecurrentExpense(id: '4', userId: 'u1', name: 'Auto OFF', amount: 500, day: 10, frequency: RecurrentFrequency.monthly, startDate: now, isActive: false, includeInSummary: true),
      ];
      
      when(() => mockGet(any())).thenAnswer((_) async => expenses);
      await cubit.loadExpenses();

      expect(cubit.state.totalStrictlyMonthly, 150.0);
      expect(cubit.state.totalMonthlyNormalized, 150.0);
    });

    test('Prorrateo debe funcionar con la nueva regla de inclusión', () async {
      final now = DateTime.now();
      final expenses = [
        RecurrentExpense(id: '1', userId: 'u1', name: 'Anual OUT', amount: 1200, day: null, frequency: RecurrentFrequency.annually, startDate: now, isActive: true, includeInSummary: false),
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
