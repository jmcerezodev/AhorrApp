import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/domain/entities/movement.dart';
import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:ahorrapp/domain/usecases/recurrent_expenses/delete_recurrent_expense_usecase.dart';
import 'package:ahorrapp/domain/usecases/recurrent_expenses/get_recurrent_expenses_usecase.dart';
import 'package:ahorrapp/domain/usecases/recurrent_expenses/save_recurrent_expense_usecase.dart';
import 'package:ahorrapp/domain/usecases/save_movement_usecase.dart';
import 'package:ahorrapp/presentation/bloc/recurrent_expenses_cubit/recurrent_expenses_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import '../../mocks/mock_definitions.dart';

class MockGetRecurrentExpensesUseCase extends Mock implements GetRecurrentExpensesUseCase {}
class MockSaveRecurrentExpenseUseCase extends Mock implements SaveRecurrentExpenseUseCase {}
class MockDeleteRecurrentExpenseUseCase extends Mock implements DeleteRecurrentExpenseUseCase {}
class MockSaveMovementUseCase extends Mock implements SaveMovementUseCase {}

class RecurrentExpenseFake extends Fake implements RecurrentExpense {}
class MovementFake extends Fake implements Movement {}

void main() {
  late RecurrentExpensesCubit cubit;
  late MockGetRecurrentExpensesUseCase mockGetUseCase;
  late MockSaveRecurrentExpenseUseCase mockSaveUseCase;
  late MockDeleteRecurrentExpenseUseCase mockDeleteUseCase;
  late MockSaveMovementUseCase mockSaveMovementUseCase;
  late MockSharedPreferences mockPrefs;

  setUpAll(() {
    registerFallbackValue(RecurrentExpenseFake());
    registerFallbackValue(MovementFake());
  });

  setUp(() {
    final getIt = GetIt.instance;
    getIt.reset();

    mockGetUseCase = MockGetRecurrentExpensesUseCase();
    mockSaveUseCase = MockSaveRecurrentExpenseUseCase();
    mockDeleteUseCase = MockDeleteRecurrentExpenseUseCase();
    mockSaveMovementUseCase = MockSaveMovementUseCase();
    mockPrefs = MockSharedPreferences();

    getIt.registerSingleton<GetRecurrentExpensesUseCase>(mockGetUseCase);
    getIt.registerSingleton<SaveRecurrentExpenseUseCase>(mockSaveUseCase);
    getIt.registerSingleton<DeleteRecurrentExpenseUseCase>(mockDeleteUseCase);
    getIt.registerSingleton<SaveMovementUseCase>(mockSaveMovementUseCase);

    Preferences.setPrefs = mockPrefs;
    when(() => mockPrefs.getBool('isProratedView')).thenReturn(false);
    when(() => mockPrefs.getString('uId')).thenReturn('user-123');

    cubit = RecurrentExpensesCubit();
  });

  tearDown(() {
    cubit.close();
  });

  group('RecurrentExpensesCubit - Unit Tests', () {
    final tExpense = RecurrentExpense(
      id: '1',
      userId: 'user-123',
      name: 'Netflix',
      amount: 15.99,
      day: 15,
      startDate: DateTime.now(),
      frequency: RecurrentFrequency.monthly,
    );

    blocTest<RecurrentExpensesCubit, RecurrentExpensesState>(
      'loadExpenses should emit [loading, success] with items',
      build: () => cubit,
      setUp: () {
        when(() => mockGetUseCase(any())).thenAnswer((_) async => [tExpense]);
      },
      act: (cubit) => cubit.loadExpenses(),
      expect: () => [
        isA<RecurrentExpensesState>().having((s) => s.status, 'status', RecurrentExpensesStatus.loading),
        isA<RecurrentExpensesState>()
            .having((s) => s.status, 'status', RecurrentExpensesStatus.success)
            .having((s) => s.expenses, 'expenses', [tExpense]),
      ],
    );

    blocTest<RecurrentExpensesCubit, RecurrentExpensesState>(
      'applyExpenseManually should call SaveMovementUseCase with correct data',
      build: () => cubit,
      setUp: () {
        when(() => mockSaveMovementUseCase.call(any())).thenAnswer((_) async => {});
      },
      act: (cubit) => cubit.applyExpenseManually(tExpense),
      verify: (_) {
        final captured = verify(() => mockSaveMovementUseCase.call(captureAny())).captured.last as Movement;
        expect(captured.name, tExpense.name);
        expect(captured.amount, tExpense.amount);
        expect(captured.isRecurrent, true);
        expect(captured.isIncome, false);
      },
    );

    group('Prorated Logic', () {
      test('totalExpenseProrated should calculate quarterly expenses correctly (amount/3)', () {
        final quarterly = tExpense.copyWith(amount: 300, frequency: RecurrentFrequency.quarterly);
        final state = RecurrentExpensesState(expenses: [quarterly]);
        expect(state.totalExpenseProrated, 100.0);
      });

      test('totalExpenseStrict should only sum monthly expenses', () {
        final quarterly = tExpense.copyWith(amount: 300, frequency: RecurrentFrequency.quarterly);
        final state = RecurrentExpensesState(expenses: [tExpense, quarterly]);
        expect(state.totalExpenseStrict, tExpense.amount);
      });
    });

    blocTest<RecurrentExpensesCubit, RecurrentExpensesState>(
      'toggleActive should update the expense state',
      build: () => cubit,
      seed: () => RecurrentExpensesState(expenses: [tExpense]),
      setUp: () {
        when(() => mockSaveUseCase(any())).thenAnswer((_) async => {});
        when(() => mockGetUseCase(any())).thenAnswer((_) async => [tExpense.copyWith(isActive: false)]);
      },
      act: (cubit) => cubit.toggleActive(tExpense),
      verify: (_) {
        final captured = verify(() => mockSaveUseCase(captureAny())).captured.last as RecurrentExpense;
        expect(captured.isActive, false);
      },
    );
  });
}
