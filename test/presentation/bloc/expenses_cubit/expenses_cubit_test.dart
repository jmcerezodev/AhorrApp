import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/domain/usecases/save_movement_usecase.dart';
import 'package:ahorrapp/presentation/bloc/history_cubit/history_cubit.dart';
import 'package:ahorrapp/presentation/bloc/expenses_cubit/expenses_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ahorrapp/domain/entities/movement.dart';

class MockSaveMovementUseCase extends Mock implements SaveMovementUseCase {}
class MockHistoryCubit extends Mock implements HistoryCubit {}
class FakeMovement extends Fake implements Movement {}

void main() {
  late ExpensesCubit expensesCubit;
  late MockSaveMovementUseCase mockSaveMovementUseCase;
  late MockHistoryCubit mockHistoryCubit;

  setUpAll(() {
    registerFallbackValue(FakeMovement());
  });

  setUp(() {
    mockSaveMovementUseCase = MockSaveMovementUseCase();
    mockHistoryCubit = MockHistoryCubit();

    getIt.reset();
    getIt.registerSingleton<SaveMovementUseCase>(mockSaveMovementUseCase);

    expensesCubit = ExpensesCubit();
  });

  group('ExpensesCubit - Limpieza de Lógica', () {
    test('Estado inicial debe ser initial y no válido', () {
      expect(expensesCubit.state.status, ExpensesStatus.initial);
      expect(expensesCubit.state.isValid, false);
    });

    test('Validación de formulario al cambiar nombre y monto', () {
      expensesCubit.expenseNameChanged('Comida');
      expensesCubit.expenseMoneyChanged('50.50');
      
      expect(expensesCubit.state.expenseName.value, 'Comida');
      expect(expensesCubit.state.expenseMoney.value, '50.50');
      expect(expensesCubit.state.isValid, true);
    });

    test('saveExpense debe pasar por posting y llegar a success', () async {
      expensesCubit.expenseNameChanged('Cine');
      expensesCubit.expenseMoneyChanged('15');
      
      when(() => mockSaveMovementUseCase.call(any())).thenAnswer((_) async => {});
      when(() => mockHistoryCubit.loadHistoryByDate(any(), any())).thenAnswer((_) async => {});

      final expectation = [
        isA<ExpensesCubitState>().having((s) => s.status, 'status', ExpensesStatus.posting),
        isA<ExpensesCubitState>().having((s) => s.status, 'status', ExpensesStatus.success),
      ];

      expectLater(expensesCubit.stream, emitsInOrder(expectation));
      await expensesCubit.saveExpense(mockHistoryCubit);

      verify(() => mockSaveMovementUseCase.call(any())).called(1);
    });

    test('saveExpense debe emitir failure si falla el guardado', () async {
      expensesCubit.expenseNameChanged('Error');
      expensesCubit.expenseMoneyChanged('10');
      
      when(() => mockSaveMovementUseCase.call(any())).thenThrow(Exception('Save error'));

      final expectation = [
        isA<ExpensesCubitState>().having((s) => s.status, 'status', ExpensesStatus.posting),
        isA<ExpensesCubitState>().having((s) => s.status, 'status', ExpensesStatus.failure),
      ];

      expectLater(expensesCubit.stream, emitsInOrder(expectation));
      await expensesCubit.saveExpense(mockHistoryCubit);
    });
  });
}
