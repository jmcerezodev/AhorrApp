import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:ahorrapp/domain/usecases/debts_loans/add_debt_loan_usecase.dart';
import 'package:ahorrapp/domain/usecases/debts_loans/delete_debt_loan_usecase.dart';
import 'package:ahorrapp/domain/usecases/debts_loans/get_debts_loans_usecase.dart';
import 'package:ahorrapp/domain/usecases/debts_loans/update_debt_loan_usecase.dart';
import 'package:ahorrapp/presentation/bloc/debts_loans_cubit/debts_loans_cubit.dart';
import 'package:ahorrapp/presentation/bloc/recurrent_expenses_cubit/recurrent_expenses_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockGetDebtsLoansUseCase extends Mock implements GetDebtsLoansUseCase {}
class MockAddDebtLoanUseCase extends Mock implements AddDebtLoanUseCase {}
class MockUpdateDebtLoanUseCase extends Mock implements UpdateDebtLoanUseCase {}
class MockDeleteDebtLoanUseCase extends Mock implements DeleteDebtLoanUseCase {}
class MockRecurrentExpensesCubit extends Mock implements RecurrentExpensesCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DebtsLoansCubit cubit;
  late MockGetDebtsLoansUseCase mockGet;
  late MockAddDebtLoanUseCase mockAdd;
  late MockUpdateDebtLoanUseCase mockUpdate;
  late MockDeleteDebtLoanUseCase mockDelete;
  late MockRecurrentExpensesCubit mockRecurrentCubit;

  setUpAll(() {
    registerFallbackValue(DebtLoan(
      id: '', userId: '', name: '', person: '', totalAmount: 0, 
      date: DateTime.now(), type: DebtLoanType.debt
    ));
    registerFallbackValue(RecurrentFrequency.monthly);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({'uId': 'user123'});
    await Preferences.init();

    mockGet = MockGetDebtsLoansUseCase();
    mockAdd = MockAddDebtLoanUseCase();
    mockUpdate = MockUpdateDebtLoanUseCase();
    mockDelete = MockDeleteDebtLoanUseCase();
    mockRecurrentCubit = MockRecurrentExpensesCubit();

    cubit = DebtsLoansCubit(
      getDebtsLoansUseCase: mockGet,
      addDebtLoanUseCase: mockAdd,
      updateDebtLoanUseCase: mockUpdate,
      deleteDebtLoanUseCase: mockDelete,
      recurrentExpensesCubit: mockRecurrentCubit,
    );
  });

  group('DebtsLoansCubit Test -', () {
    final tDebt = DebtLoan(
      id: '1', userId: 'user123', name: 'Coche', person: 'Banco', 
      totalAmount: 1000, paidAmount: 200, type: DebtLoanType.debt
    );

    test('El estado inicial debe estar vacío', () {
      expect(cubit.state.debtsLoans, isEmpty);
      expect(cubit.state.isLoading, false);
    });

    test('loadDebtsLoans debe cargar deudas y actualizar estado', () async {
      when(() => mockGet(any())).thenAnswer((_) async => [tDebt]);
      
      await cubit.loadDebtsLoans();

      expect(cubit.state.debtsLoans, [tDebt]);
      expect(cubit.state.isLoading, false);
      verify(() => mockGet('user123')).called(1);
    });

    test('addPayment debe actualizar el importe pagado y marcar como completada si aplica', () async {
      when(() => mockGet(any())).thenAnswer((_) async => [tDebt]);
      when(() => mockUpdate(any())).thenAnswer((_) async => {});
      
      await cubit.loadDebtsLoans();
      await cubit.addPayment('1', 800);

      final captured = verify(() => mockUpdate(captureAny())).captured.first as DebtLoan;
      expect(captured.paidAmount, 1000);
      expect(captured.isCompleted, true);
    });

    test('deleteDebtLoan debe llamar al caso de uso y recargar', () async {
      when(() => mockDelete(any())).thenAnswer((_) async => {});
      when(() => mockGet(any())).thenAnswer((_) async => []);

      await cubit.deleteDebtLoan('1');

      verify(() => mockDelete('1')).called(1);
      verify(() => mockGet('user123')).called(1);
    });

    test('addOrUpdateDebtLoan debe vincular con recurrentes si se solicita', () async {
      when(() => mockAdd(any())).thenAnswer((_) async => {});
      when(() => mockGet(any())).thenAnswer((_) async => []);
      when(() => mockRecurrentCubit.addOrUpdateExpense(
        id: any(named: 'id'),
        name: any(named: 'name'),
        amount: any(named: 'amount'),
        day: any(named: 'day'),
        category: any(named: 'category'),
        frequency: any(named: 'frequency'),
        startDate: any(named: 'startDate'),
      )).thenAnswer((_) async => {});

      await cubit.addOrUpdateDebtLoan(
        name: 'Préstamo', 
        person: 'Amigo', 
        totalAmount: 500, 
        type: DebtLoanType.loan,
        isInstallment: true,
        installmentAmount: 50,
        addToRecurrent: true,
      );

      verify(() => mockRecurrentCubit.addOrUpdateExpense(
        id: any(named: 'id'),
        name: any(named: 'name', that: contains('Préstamo')),
        amount: 50,
        day: any(named: 'day'),
        category: 'deudas',
        frequency: any(named: 'frequency'),
        startDate: any(named: 'startDate'),
      )).called(1);
      verify(() => mockAdd(any())).called(1);
    });
  });
}
