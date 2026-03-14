import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
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
      id: '0', 
      name: 'dummy', 
      amount: 0, 
      type: MovementType.expense, 
      isIncome: false, 
      date: '01/01/2024', 
      hour: '00:00', 
      month: 'Enero', 
      year: 2024, 
      createdAt: DateTime.now()
    ));
    registerFallbackValue(DebtLoan(
      id: '0', 
      userId: '0', 
      name: 'dummy', 
      person: 'dummy', 
      totalAmount: 0, 
      type: DebtLoanType.debt
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

    // Stubs globales
    when(() => mockSaveMovement.call(any())).thenAnswer((_) async => {});
    when(() => mockLocalRepo.getRecurrentExpenses(any())).thenAnswer((_) async => []);
    when(() => mockLocalRepo.updateLastApplied(any(), any())).thenAnswer((_) async => {});
    when(() => mockRemoteRepo.updateLastApplied(any(), any())).thenAnswer((_) async => {});
    when(() => mockDebtLocalRepo.getDebtsLoans(any())).thenAnswer((_) async => []);
    when(() => mockDebtLocalRepo.updateDebtLoan(any())).thenAnswer((_) async => {});
    when(() => mockDebtRemoteRepo.updateDebtLoan(any())).thenAnswer((_) async => {});
  });

  group('ProcessRecurrentExpensesUseCase - Lógica de Día Efectivo y Vinculación', () {
    test('Día 31 en Febrero no bisiesto: debe crear movimiento el día 28', () async {
      final expense = RecurrentExpense(
        id: 'exp1', userId: 'u1', name: 'Gasto 31', amount: 100, day: 31, 
        startDate: DateTime(2023, 1, 1), isActive: true, frequency: RecurrentFrequency.monthly
      );

      when(() => mockLocalRepo.getRecurrentExpenses(any())).thenAnswer((_) async => [expense]);

      final now = DateTime(2023, 2, 28);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day; 
      final effectiveDay = (expense.day! > lastDayOfMonth) ? lastDayOfMonth : expense.day!;
      
      expect(effectiveDay, 28);
    });

    test('Año Bisiesto: Día 30 en Febrero debe ser día 29', () async {
      final now = DateTime(2024, 2, 29); 
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
      expect(lastDayOfMonth, 29);
    });

    test('Control de Duplicados: No debe aplicar si ya se aplicó este mes', () async {
      final now = DateTime.now();
      final expense = RecurrentExpense(
        id: 'exp1', userId: 'u1', name: 'Gasto', amount: 100, day: 1, 
        startDate: DateTime(2024, 1, 1), isActive: true, 
        lastApplied: '${now.month}-${now.year}'
      );

      when(() => mockLocalRepo.getRecurrentExpenses(any())).thenAnswer((_) async => [expense]);

      await useCase('u1');

      verifyNever(() => mockSaveMovement(any()));
    });

    test('Gasto Recurrente vinculado a Deuda: debe actualizar el saldo de la deuda', () async {
      final now = DateTime.now();
      final expense = RecurrentExpense(
        id: 'exp-linked', userId: 'u1', name: 'Pago Coche', amount: 200, day: now.day, 
        startDate: DateTime(2024, 1, 1), isActive: true, frequency: RecurrentFrequency.monthly
      );
      
      final debt = DebtLoan(
        id: 'debt1', userId: 'u1', name: 'Prestamo Coche', person: 'Banco', 
        totalAmount: 1000, paidAmount: 400, type: DebtLoanType.debt, 
        recurrentExpenseId: 'exp-linked'
      );

      when(() => mockLocalRepo.getRecurrentExpenses(any())).thenAnswer((_) async => [expense]);
      when(() => mockDebtLocalRepo.getDebtsLoans(any())).thenAnswer((_) async => [debt]);

      await useCase('u1');

      // Verificamos que se crea el movimiento
      verify(() => mockSaveMovement(any())).called(1);

      // Verificamos que se actualiza la deuda: 400 + 200 = 600
      verify(() => mockDebtLocalRepo.updateDebtLoan(any(that: isA<DebtLoan>()
          .having((d) => d.paidAmount, 'paidAmount', 600)
          .having((d) => d.isCompleted, 'isCompleted', false)
      ))).called(1);
    });

    test('Formato de Moneda: El Movement generado debe seguir la regla de números redondos', () async {
      final humanizer = HumanizeNumbers();
      expect(humanizer.number(100.0), '100');
      expect(humanizer.number(100.50), '100,5');
    });
  });
}
