import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/domain/entities/movement.dart';
import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:ahorrapp/domain/repositories/debt_loan_repository.dart';
import 'package:ahorrapp/domain/repositories/i_recurrent_expense_repository.dart';
import 'package:ahorrapp/domain/usecases/recurrent_expenses/process_recurrent_expenses_usecase.dart';
import 'package:ahorrapp/domain/usecases/save_movement_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRecurrentExpenseRepository extends Mock implements IRecurrentExpenseRepository {}
class MockDebtLoanRepository extends Mock implements DebtLoanRepository {}
class MockSaveMovementUseCase extends Mock implements SaveMovementUseCase {}

void main() {
  late ProcessRecurrentExpensesUseCase useCase;
  late MockRecurrentExpenseRepository mockLocalRepo;
  late MockRecurrentExpenseRepository mockRemoteRepo;
  late MockDebtLoanRepository mockDebtLocalRepo;
  late MockDebtLoanRepository mockDebtRemoteRepo;
  late MockSaveMovementUseCase mockSaveMovement;

  setUpAll(() {
    registerFallbackValue(Movement(
      id: '', name: '', amount: 0, type: MovementType.expense, 
      isIncome: false, date: '', hour: '', month: '', year: 0, createdAt: DateTime.now()
    ));
    registerFallbackValue(DebtLoan(
      id: '', userId: '', name: '', person: '', totalAmount: 0, 
      type: DebtLoanType.debt, date: DateTime.now()
    ));
  });

  setUp(() {
    mockLocalRepo = MockRecurrentExpenseRepository();
    mockRemoteRepo = MockRecurrentExpenseRepository();
    mockDebtLocalRepo = MockDebtLoanRepository();
    mockDebtRemoteRepo = MockDebtLoanRepository();
    mockSaveMovement = MockSaveMovementUseCase();

    useCase = ProcessRecurrentExpensesUseCase(
      localRepository: mockLocalRepo,
      remoteRepository: mockRemoteRepo,
      debtLocalRepository: mockDebtLocalRepo,
      debtRemoteRepository: mockDebtRemoteRepo,
      saveMovementUseCase: mockSaveMovement,
    );
  });

  group('ProcessRecurrentExpensesUseCase - Sincronización de Deudas', () {
    final now = DateTime.now();
    final expense = RecurrentExpense(
      id: 'exp1', userId: 'u1', name: 'Gasto', amount: 100, day: now.day, 
      frequency: RecurrentFrequency.monthly, startDate: now, lastApplied: null
    );

    final debt = DebtLoan(
      id: 'debt1', userId: 'u1', name: 'Deuda', person: 'Juan', 
      totalAmount: 1000, paidAmount: 0, type: DebtLoanType.debt, 
      recurrentExpenseId: 'exp1'
    );

    test('debe aplicar el gasto y actualizar el progreso de la deuda vinculada', () async {
      when(() => mockLocalRepo.getRecurrentExpenses(any())).thenAnswer((_) async => [expense]);
      when(() => mockDebtLocalRepo.getDebtsLoans(any())).thenAnswer((_) async => [debt]);
      when(() => mockSaveMovement(any())).thenAnswer((_) async => {});
      when(() => mockDebtLocalRepo.updateDebtLoan(any())).thenAnswer((_) async => {});
      when(() => mockDebtRemoteRepo.updateDebtLoan(any())).thenAnswer((_) async => {});
      when(() => mockLocalRepo.updateLastApplied(any(), any())).thenAnswer((_) async => {});
      when(() => mockRemoteRepo.updateLastApplied(any(), any())).thenAnswer((_) async => {});

      await useCase('u1');

      // Verificamos que se guardó el movimiento
      verify(() => mockSaveMovement(any())).called(1);
      
      // Verificamos que se actualizó la deuda con el nuevo importe pagado (0 + 100)
      final capturedDebt = verify(() => mockDebtLocalRepo.updateDebtLoan(captureAny())).captured.first as DebtLoan;
      expect(capturedDebt.paidAmount, 100);
      expect(capturedDebt.isCompleted, false);
    });

    test('debe marcar la deuda como completada si el pago alcanza el total', () async {
      final almostPaidDebt = debt.copyWith(paidAmount: 900);
      
      when(() => mockLocalRepo.getRecurrentExpenses(any())).thenAnswer((_) async => [expense]);
      when(() => mockDebtLocalRepo.getDebtsLoans(any())).thenAnswer((_) async => [almostPaidDebt]);
      when(() => mockSaveMovement(any())).thenAnswer((_) async => {});
      when(() => mockDebtLocalRepo.updateDebtLoan(any())).thenAnswer((_) async => {});
      when(() => mockDebtRemoteRepo.updateDebtLoan(any())).thenAnswer((_) async => {});
      when(() => mockLocalRepo.updateLastApplied(any(), any())).thenAnswer((_) async => {});
      when(() => mockRemoteRepo.updateLastApplied(any(), any())).thenAnswer((_) async => {});

      await useCase('u1');

      final capturedDebt = verify(() => mockDebtLocalRepo.updateDebtLoan(captureAny())).captured.first as DebtLoan;
      expect(capturedDebt.paidAmount, 1000);
      expect(capturedDebt.isCompleted, true);
    });
  });
}
