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

  group('ExpensesCubit - Lógica de Gastos y Categorías', () {
    test('Estado inicial debe tener categoría general', () {
      expect(expensesCubit.state.status, ExpensesStatus.initial);
      expect(expensesCubit.state.category, 'general');
    });

    test('categoryChanged debe actualizar la categoría en el estado', () {
      expensesCubit.categoryChanged('hogar');
      expect(expensesCubit.state.category, 'hogar');
    });

    test('saveExpense debe incluir la categoría seleccionada', () async {
      expensesCubit.expenseNameChanged('Cine');
      expensesCubit.expenseMoneyChanged('15');
      expensesCubit.categoryChanged('ocio');
      
      when(() => mockSaveMovementUseCase.call(any())).thenAnswer((_) async => {});
      when(() => mockHistoryCubit.loadHistoryByDate(any(), any())).thenAnswer((_) async => {});

      await expensesCubit.saveExpense(mockHistoryCubit);

      final captured = verify(() => mockSaveMovementUseCase.call(captureAny())).captured.first as Movement;
      expect(captured.category, 'ocio');
      expect(expensesCubit.state.status, ExpensesStatus.success);
    });

    test('saveExpense debe emitir failure si falla el guardado', () async {
      expensesCubit.expenseNameChanged('Error');
      expensesCubit.expenseMoneyChanged('10');
      
      when(() => mockSaveMovementUseCase.call(any())).thenThrow(Exception('Save error'));

      await expensesCubit.saveExpense(mockHistoryCubit);
      expect(expensesCubit.state.status, ExpensesStatus.failure);
    });
  });
}
