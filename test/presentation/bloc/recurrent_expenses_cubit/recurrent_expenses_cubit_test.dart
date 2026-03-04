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
    SharedPreferences.setMockInitialValues({'uId': 'user123'});
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

  group('RecurrentExpensesCubit Tests', () {
    test('Estado inicial debe ser correcto', () {
      expect(cubit.state.status, RecurrentExpensesStatus.initial);
      expect(cubit.state.expenses, isEmpty);
    });

    test('loadExpenses debe emitir success con lista de gastos', () async {
      final expenses = [RecurrentExpense(
        id: '1', 
        userId: 'u1', 
        name: 'Gasto', 
        amount: 10, 
        day: 1, 
        startDate: DateTime.now(),
        position: 0,
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
      // GIVEN: Una lista con 3 elementos
      final e1 = RecurrentExpense(id: '1', userId: 'u1', name: 'A', amount: 10, startDate: DateTime.now(), position: 0);
      final e2 = RecurrentExpense(id: '2', userId: 'u1', name: 'B', amount: 20, startDate: DateTime.now(), position: 1);
      final e3 = RecurrentExpense(id: '3', userId: 'u1', name: 'C', amount: 30, startDate: DateTime.now(), position: 2);
      
      when(() => mockGet(any())).thenAnswer((_) async => [e1, e2, e3]);
      when(() => mockSave(any())).thenAnswer((_) async => {});
      
      await cubit.loadExpenses();

      // WHEN: Movemos el primer elemento (A) al final
      await cubit.reorderExpenses(0, 3);

      // THEN: El estado debe reflejar el nuevo orden [B, C, A] con posiciones [0, 1, 2]
      expect(cubit.state.expenses[0].id, '2');
      expect(cubit.state.expenses[0].position, 0);
      expect(cubit.state.expenses[1].id, '3');
      expect(cubit.state.expenses[1].position, 1);
      expect(cubit.state.expenses[2].id, '1');
      expect(cubit.state.expenses[2].position, 2);

      // Y debe haber llamado a guardar para cada uno de los 3 elementos
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
        id: '1', 
        userId: 'u1', 
        name: 'Gasto', 
        amount: 10, 
        day: 1, 
        isActive: true, 
        startDate: DateTime.now(),
        position: 0,
      );
      when(() => mockSave(any())).thenAnswer((_) async => {});
      when(() => mockGet(any())).thenAnswer((_) async => []);

      await cubit.toggleActive(expense);

      final captured = verify(() => mockSave(captureAny())).captured.first as RecurrentExpense;
      expect(captured.isActive, false);
    });

    test('applyExpenseManually debe crear un movimiento real', () async {
      final expense = RecurrentExpense(
        id: '1', 
        userId: 'u1', 
        name: 'Netflix', 
        amount: 10, 
        day: 1, 
        startDate: DateTime.now(),
        position: 0,
      );
      when(() => mockSaveMovement(any())).thenAnswer((_) async => {});

      await cubit.applyExpenseManually(expense);

      verify(() => mockSaveMovement(any())).called(1);
    });
  });
}
