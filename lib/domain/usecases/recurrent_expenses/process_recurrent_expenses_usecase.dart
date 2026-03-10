import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/domain/entities/movement.dart';
import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:ahorrapp/domain/repositories/debt_loan_repository.dart';
import 'package:ahorrapp/domain/repositories/i_recurrent_expense_repository.dart';
import 'package:ahorrapp/domain/usecases/save_movement_usecase.dart';
import 'package:uuid/uuid.dart';

class ProcessRecurrentExpensesUseCase {
  final IRecurrentExpenseRepository localRepository;
  final IRecurrentExpenseRepository remoteRepository;
  final DebtLoanRepository debtLocalRepository;
  final DebtLoanRepository debtRemoteRepository;
  final SaveMovementUseCase saveMovementUseCase;

  ProcessRecurrentExpensesUseCase({
    required this.localRepository,
    required this.remoteRepository,
    required this.debtLocalRepository,
    required this.debtRemoteRepository,
    required this.saveMovementUseCase,
  });

  Future<void> call(String userId) async {
    final expenses = await localRepository.getRecurrentExpenses(userId);
    final debts = await debtLocalRepository.getDebtsLoans(userId);
    final now = DateTime.now();
    final dateService = Date();

    for (final expense in expenses) {
      // Solo procesamos automáticos activos
      if (!expense.isActive || expense.day == null) continue;

      if (_shouldApply(expense, now)) {
        // 1. Crear el movimiento en el historial
        final movement = Movement(
          id: const Uuid().v4(),
          name: expense.name,
          amount: expense.amount,
          type: MovementType.expense,
          isIncome: false,
          date: dateService.currentDate(),
          hour: dateService.currentHour(),
          month: dateService.monthNames(),
          year: now.year,
          createdAt: DateTime.now(),
          isRecurrent: true,
        );

        await saveMovementUseCase(movement);

        // 2. Actualizar la Deuda vinculada si existe
        try {
          final linkedDebt = debts.where((d) => d.recurrentExpenseId == expense.id).firstOrNull;
          if (linkedDebt != null) {
            final newPaidAmount = linkedDebt.paidAmount + expense.amount;
            final updatedDebt = linkedDebt.copyWith(
              paidAmount: newPaidAmount,
              isCompleted: newPaidAmount >= linkedDebt.totalAmount,
            );
            
            await debtLocalRepository.updateDebtLoan(updatedDebt);
            try {
              await debtRemoteRepository.updateDebtLoan(updatedDebt);
            } catch (_) {}
          }
        } catch (_) {}

        // 3. Actualizar fecha de última aplicación (MM-YYYY)
        final lastAppliedKey = "${now.month}-${now.year}";
        await localRepository.updateLastApplied(expense.id, lastAppliedKey);
        
        try {
          await remoteRepository.updateLastApplied(expense.id, lastAppliedKey);
        } catch (_) {}
      }
    }
  }

  bool _shouldApply(RecurrentExpense expense, DateTime now) {
    if (now.day < expense.day!) return false;
    if (expense.lastApplied == null) return true;

    final parts = expense.lastApplied!.split('-');
    final lastMonth = int.parse(parts[0]);
    final lastYear = int.parse(parts[1]);

    final monthsDiff = (now.year - lastYear) * 12 + (now.month - lastMonth);

    switch (expense.frequency) {
      case RecurrentFrequency.monthly:
        return monthsDiff >= 1;
      case RecurrentFrequency.quarterly:
        return monthsDiff >= 3;
      case RecurrentFrequency.semiAnnually:
        return monthsDiff >= 6;
      case RecurrentFrequency.annually:
        return monthsDiff >= 12;
    }
  }
}
