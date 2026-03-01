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

  group('IncomesCubit - Limpieza de Lógica', () {
    
    test('1. El estado inicial DEBE ser "initial" (No invalid)', () {
      // Este test fallará porque tu código actual usa 'invalid' como inicio
      expect(incomesCubit.state.status, IncomesStatus.initial);
    });

    test('2. No debe validar el formulario hasta que el usuario escriba (Pure state)', () {
      expect(incomesCubit.state.incomeName.isPure, true);
      expect(incomesCubit.state.isValid, false);
    });

    test('3. Debe pasar a "posting" y luego a "success" al guardar correctamente', () async {
      incomesCubit.incomeNameChanged('Sueldo');
      incomesCubit.incomeMoneyChanged('1000');

      when(() => mockSaveMovementUseCase.call(any())).thenAnswer((_) async => {});
      when(() => mockHistoryCubit.loadHistoryByDate(any(), any())).thenAnswer((_) async => {});

      final expectation = [
        // Al empezar a guardar, el estado debe ser posting
        isA<IncomesCubitState>().having((s) => s.status, 'status', IncomesStatus.posting),
        // Al terminar, debe ser success
        isA<IncomesCubitState>().having((s) => s.status, 'status', IncomesStatus.success),
      ];

      expectLater(incomesCubit.stream, emitsInOrder(expectation));
      await incomesCubit.saveIncome(mockHistoryCubit);
    });

    test('4. Debe pasar a "failure" si falla el servidor (No invalid)', () async {
      incomesCubit.incomeNameChanged('Sueldo');
      incomesCubit.incomeMoneyChanged('1000');

      when(() => mockSaveMovementUseCase.call(any())).thenThrow(Exception('Network Error'));

      final expectation = [
        isA<IncomesCubitState>().having((s) => s.status, 'status', IncomesStatus.posting),
        isA<IncomesCubitState>().having((s) => s.status, 'status', IncomesStatus.failure),
      ];

      expectLater(incomesCubit.stream, emitsInOrder(expectation));
      await incomesCubit.saveIncome(mockHistoryCubit);
    });
  });
}
