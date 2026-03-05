import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/domain/usecases/save_movement_usecase.dart';
import 'package:ahorrapp/presentation/bloc/history_cubit/history_cubit.dart';
import 'package:ahorrapp/presentation/bloc/incomes_cubit/incomes_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ahorrapp/domain/entities/movement.dart';

class MockSaveMovementUseCase extends Mock implements SaveMovementUseCase {}
class MockHistoryCubit extends Mock implements HistoryCubit {}
class FakeMovement extends Fake implements Movement {}

void main() {
  late IncomesCubit incomesCubit;
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
    incomesCubit = IncomesCubit();
  });

  group('IncomesCubit - Lógica de Ingresos y Categorías', () {
    
    test('1. El estado inicial DEBE ser "initial" y categoría "otro"', () {
      expect(incomesCubit.state.status, IncomesStatus.initial);
      expect(incomesCubit.state.category, 'otro');
    });

    test('2. categoryChanged debe actualizar la categoría en el estado', () {
      incomesCubit.categoryChanged('nómina');
      expect(incomesCubit.state.category, 'nómina');
    });

    test('3. Debe guardar el ingreso con la categoría seleccionada', () async {
      incomesCubit.incomeNameChanged('Sueldo');
      incomesCubit.incomeMoneyChanged('1000');
      incomesCubit.categoryChanged('nómina');

      when(() => mockSaveMovementUseCase.call(any())).thenAnswer((_) async => {});
      when(() => mockHistoryCubit.loadHistoryByDate(any(), any())).thenAnswer((_) async => {});

      await incomesCubit.saveIncome(mockHistoryCubit);

      // Verificamos que se llamó al caso de uso con la categoría correcta
      final captured = verify(() => mockSaveMovementUseCase.call(captureAny())).captured.first as Movement;
      expect(captured.category, 'nómina');
      expect(incomesCubit.state.status, IncomesStatus.success);
    });

    test('4. Debe pasar a "failure" si falla el servidor', () async {
      incomesCubit.incomeNameChanged('Sueldo');
      incomesCubit.incomeMoneyChanged('1000');

      when(() => mockSaveMovementUseCase.call(any())).thenThrow(Exception('Network Error'));

      await incomesCubit.saveIncome(mockHistoryCubit);
      expect(incomesCubit.state.status, IncomesStatus.failure);
    });
  });
}
