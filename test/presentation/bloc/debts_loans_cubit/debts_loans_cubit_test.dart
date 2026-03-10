import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/domain/entities/movement.dart';
import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:ahorrapp/domain/usecases/debts_loans/add_debt_loan_usecase.dart';
import 'package:ahorrapp/domain/usecases/debts_loans/delete_debt_loan_usecase.dart';
import 'package:ahorrapp/domain/usecases/debts_loans/get_debts_loans_usecase.dart';
import 'package:ahorrapp/domain/usecases/debts_loans/update_debt_loan_usecase.dart';
import 'package:ahorrapp/domain/usecases/save_movement_usecase.dart';
import 'package:ahorrapp/presentation/bloc/debts_loans_cubit/debts_loans_cubit.dart';
import 'package:ahorrapp/presentation/bloc/recurrent_expenses_cubit/recurrent_expenses_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockGetDebtsLoansUseCase extends Mock implements GetDebtsLoansUseCase {}
class MockAddDebtLoanUseCase extends Mock implements AddDebtLoanUseCase {}
class MockUpdateDebtLoanUseCase extends Mock implements UpdateDebtLoanUseCase {}
class MockDeleteDebtLoanUseCase extends Mock implements DeleteDebtLoanUseCase {}
class MockRecurrentExpensesCubit extends Mock implements RecurrentExpensesCubit {}
class MockSaveMovementUseCase extends Mock implements SaveMovementUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DebtsLoansCubit cubit;
  late MockGetDebtsLoansUseCase mockGet;
  late MockAddDebtLoanUseCase mockAdd;
  late MockUpdateDebtLoanUseCase mockUpdate;
  late MockDeleteDebtLoanUseCase mockDelete;
  late MockRecurrentExpensesCubit mockRecurrentCubit;
  late MockSaveMovementUseCase mockSaveMovement;

  setUpAll(() {
    registerFallbackValue(DebtLoan(
      id: '', userId: '', name: '', person: '', totalAmount: 0, 
      date: DateTime.now(), type: DebtLoanType.debt
    ));
    registerFallbackValue(RecurrentFrequency.monthly);
    registerFallbackValue(Movement(
      id: '', name: '', amount: 0, type: MovementType.expense, 
      isIncome: false, date: '', hour: '', month: '', year: 0, createdAt: DateTime.now()
    ));
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({'uId': 'user123'});
    await Preferences.init();

    mockGet = MockGetDebtsLoansUseCase();
    mockAdd = MockAddDebtLoanUseCase();
    mockUpdate = MockUpdateDebtLoanUseCase();
    mockDelete = MockDeleteDebtLoanUseCase();
    mockRecurrentCubit = MockRecurrentExpensesCubit();
    mockSaveMovement = MockSaveMovementUseCase();

    // Setup Service Locator - Reset and Register
    final getIt = GetIt.instance;
    await getIt.reset();
    getIt.registerSingleton<SaveMovementUseCase>(mockSaveMovement);

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
      id: '1', userId: 'user123', name: 'Cena', person: 'Juan', 
      totalAmount: 1000, paidAmount: 200, type: DebtLoanType.debt,
      isInstallment: false,
    );

    final tLoan = DebtLoan(
      id: '2', userId: 'user123', name: 'Bizum', person: 'Pedro', 
      totalAmount: 50, paidAmount: 0, type: DebtLoanType.loan,
      isInstallment: false,
    );

    final tInstallmentDebt = DebtLoan(
      id: '3', userId: 'user123', name: 'Coche', person: 'Banco', 
      totalAmount: 5000, paidAmount: 1000, type: DebtLoanType.debt,
      isInstallment: true,
      installmentAmount: 200,
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

    group('addPayment -', () {
      test('debe actualizar el importe pagado y marcar como completada si aplica', () async {
        when(() => mockGet(any())).thenAnswer((_) async => [tDebt]);
        when(() => mockUpdate(any())).thenAnswer((_) async => {});
        
        await cubit.loadDebtsLoans();
        await cubit.addPayment('1', 800);

        final captured = verify(() => mockUpdate(captureAny())).captured.first as DebtLoan;
        expect(captured.paidAmount, 1000);
        expect(captured.isCompleted, true);
      });

      test('debe registrar movimiento en historial como gasto si es DEUDA y !isInstallment y addToHistory: true', () async {
        when(() => mockGet(any())).thenAnswer((_) async => [tDebt]);
        when(() => mockUpdate(any())).thenAnswer((_) async => {});
        when(() => mockSaveMovement(any())).thenAnswer((_) async => {});
        
        await cubit.loadDebtsLoans();
        await cubit.addPayment('1', 100, addToHistory: true);

        final capturedMovement = verify(() => mockSaveMovement(captureAny())).captured.first as Movement;
        expect(capturedMovement.name, 'Cena');
        expect(capturedMovement.amount, 100);
        expect(capturedMovement.type, MovementType.expense);
        expect(capturedMovement.isIncome, false);
        expect(capturedMovement.category, 'deudas');
      });

      test('debe registrar movimiento en historial como ingreso si es PRÉSTAMO y !isInstallment y addToHistory: true', () async {
        when(() => mockGet(any())).thenAnswer((_) async => [tLoan]);
        when(() => mockUpdate(any())).thenAnswer((_) async => {});
        when(() => mockSaveMovement(any())).thenAnswer((_) async => {});
        
        await cubit.loadDebtsLoans();
        await cubit.addPayment('2', 20, addToHistory: true);

        final capturedMovement = verify(() => mockSaveMovement(captureAny())).captured.first as Movement;
        expect(capturedMovement.name, 'Bizum');
        expect(capturedMovement.amount, 20);
        expect(capturedMovement.type, MovementType.income);
        expect(capturedMovement.isIncome, true);
      });

      test('NO debe registrar movimiento en historial si addToHistory es false', () async {
        when(() => mockGet(any())).thenAnswer((_) async => [tDebt]);
        when(() => mockUpdate(any())).thenAnswer((_) async => {});
        
        await cubit.loadDebtsLoans();
        await cubit.addPayment('1', 100, addToHistory: false);

        verifyNever(() => mockSaveMovement(any()));
      });

      test('NO debe registrar movimiento en historial aunque addToHistory sea true si es a PLAZOS', () async {
        when(() => mockGet(any())).thenAnswer((_) async => [tInstallmentDebt]);
        when(() => mockUpdate(any())).thenAnswer((_) async => {});
        
        await cubit.loadDebtsLoans();
        await cubit.addPayment('3', 200, addToHistory: true);

        verifyNever(() => mockSaveMovement(any()));
      });
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
