import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/domain/usecases/debts_loans/add_debt_loan_usecase.dart';
import 'package:ahorrapp/domain/usecases/debts_loans/delete_debt_loan_usecase.dart';
import 'package:ahorrapp/domain/usecases/debts_loans/get_debts_loans_usecase.dart';
import 'package:ahorrapp/domain/usecases/debts_loans/update_debt_loan_usecase.dart';
import 'package:ahorrapp/presentation/bloc/debts_loans_cubit/debts_loans_cubit.dart';
import 'package:ahorrapp/presentation/bloc/recurrent_expenses_cubit/recurrent_expenses_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../mocks/mock_definitions.dart';

class MockGetDebtsLoansUseCase extends Mock implements GetDebtsLoansUseCase {}
class MockAddDebtLoanUseCase extends Mock implements AddDebtLoanUseCase {}
class MockUpdateDebtLoanUseCase extends Mock implements UpdateDebtLoanUseCase {}
class MockDeleteDebtLoanUseCase extends Mock implements DeleteDebtLoanUseCase {}
class MockRecurrentExpensesCubit extends Mock implements RecurrentExpensesCubit {}

class DebtLoanFake extends Fake implements DebtLoan {}

void main() {
  setUpAll(() {
    registerFallbackValue(DebtLoanFake());
  });

  late DebtsLoansCubit cubit;
  late MockGetDebtsLoansUseCase mockGetUseCase;
  late MockAddDebtLoanUseCase mockAddUseCase;
  late MockUpdateDebtLoanUseCase mockUpdateUseCase;
  late MockDeleteDebtLoanUseCase mockDeleteUseCase;
  late MockRecurrentExpensesCubit mockRecurrentCubit;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockGetUseCase = MockGetDebtsLoansUseCase();
    mockAddUseCase = MockAddDebtLoanUseCase();
    mockUpdateUseCase = MockUpdateDebtLoanUseCase();
    mockDeleteUseCase = MockDeleteDebtLoanUseCase();
    mockRecurrentCubit = MockRecurrentExpensesCubit();
    mockPrefs = MockSharedPreferences();

    Preferences.setPrefs = mockPrefs;
    when(() => mockPrefs.getString('uId')).thenReturn('user-123');

    cubit = DebtsLoansCubit(
      getDebtsLoansUseCase: mockGetUseCase,
      addDebtLoanUseCase: mockAddUseCase,
      updateDebtLoanUseCase: mockUpdateUseCase,
      deleteDebtLoanUseCase: mockDeleteUseCase,
      recurrentExpensesCubit: mockRecurrentCubit,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('DebtsLoansCubit - Unit Tests', () {
    final tDebt = DebtLoan(
      id: '1',
      userId: 'user-123',
      name: 'Credit Card',
      person: 'Bank',
      totalAmount: 1000.0,
      paidAmount: 200.0,
      type: DebtLoanType.debt,
    );

    blocTest<DebtsLoansCubit, DebtsLoansState>(
      'loadDebtsLoans should emit [isLoading: true, isLoading: false] with items',
      build: () => cubit,
      setUp: () {
        when(() => mockGetUseCase(any())).thenAnswer((_) async => [tDebt]);
      },
      act: (cubit) => cubit.loadDebtsLoans(),
      expect: () => [
        isA<DebtsLoansState>().having((s) => s.isLoading, 'isLoading', true),
        isA<DebtsLoansState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.debtsLoans, 'items', [tDebt]),
      ],
    );

    test('Debt remainingAmount calculation should be correct', () {
      expect(tDebt.remainingAmount, 800.0);
    });

    blocTest<DebtsLoansCubit, DebtsLoansState>(
      'addPayment should update paidAmount and mark as completed if balance is 0',
      build: () => cubit,
      seed: () => DebtsLoansState(debtsLoans: [tDebt]),
      setUp: () {
        when(() => mockUpdateUseCase(any())).thenAnswer((_) async => {});
        when(() => mockGetUseCase(any())).thenAnswer((_) async => []);
      },
      act: (cubit) => cubit.addPayment('1', 800.0),
      verify: (_) {
        final captured = verify(() => mockUpdateUseCase(captureAny())).captured.last as DebtLoan;
        expect(captured.paidAmount, 1000.0);
        expect(captured.isCompleted, true);
      },
    );

    blocTest<DebtsLoansCubit, DebtsLoansState>(
      'totalDebts should only sum pending debts',
      build: () => cubit,
      act: (cubit) {}, // Just checking getter
      verify: (_) {
        final state = DebtsLoansState(debtsLoans: [
          tDebt, // 800 pending
          tDebt.copyWith(id: '2', totalAmount: 500, paidAmount: 500, isCompleted: true), // 0 pending
          tDebt.copyWith(id: '3', type: DebtLoanType.loan, totalAmount: 200), // 0 debt (it's a loan)
        ]);
        expect(state.totalDebts, 800.0);
      },
    );

    blocTest<DebtsLoansCubit, DebtsLoansState>(
      'totalLoans should only sum pending loans',
      build: () => cubit,
      act: (cubit) {},
      verify: (_) {
        final state = DebtsLoansState(debtsLoans: [
          tDebt.copyWith(id: '3', type: DebtLoanType.loan, totalAmount: 500, paidAmount: 100), // 400 pending loan
        ]);
        expect(state.totalLoans, 400.0);
      },
    );

    group('Debts vs Loans Logic', () {
      test('remainingAmount should work for both types', () {
        final loan = tDebt.copyWith(type: DebtLoanType.loan, totalAmount: 500, paidAmount: 100);
        expect(loan.remainingAmount, 400.0);
      });
    });
  });
}
