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
      startDate: DateTime.now()
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
        startDate: DateTime.now()
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
        startDate: DateTime.now()
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
        startDate: DateTime.now()
      );
      when(() => mockSaveMovement(any())).thenAnswer((_) async => {});

      await cubit.applyExpenseManually(expense);

      verify(() => mockSaveMovement(any())).called(1);
    });
  });
}
