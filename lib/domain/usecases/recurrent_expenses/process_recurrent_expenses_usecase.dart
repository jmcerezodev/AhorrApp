import 'package:ahorrapp/core/date/date.dart';
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

      // Calcular el día efectivo de cobro para el mes actual
      final int lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
      final int effectiveDay = (expense.day! > lastDayOfMonth) 
          ? lastDayOfMonth 
          : expense.day!;

      if (_shouldApply(expense, now, effectiveDay)) {
        // 1. Crear el movimiento en el historial (Ingreso o Gasto)
        final String effectiveDate = "$effectiveDay/${now.month}/${now.year}";

        final movement = Movement(
          id: const Uuid().v4(),
          name: expense.name,
          amount: expense.amount,
          type: expense.isIncome ? MovementType.income : MovementType.expense,
          isIncome: expense.isIncome,
          date: effectiveDate,
          hour: dateService.currentHour(),
          month: dateService.monthNames(),
          year: now.year,
          createdAt: DateTime.now(),
          isRecurrent: true,
        );

        await saveMovementUseCase(movement);

        // 2. Actualizar la Deuda/Préstamo vinculado si existe
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

        // 3. Actualizar fecha de última aplicación (M-YYYY)
        final lastAppliedKey = "${now.month}-${now.year}";
        await localRepository.updateLastApplied(expense.id, lastAppliedKey);
        
        try {
          await remoteRepository.updateLastApplied(expense.id, lastAppliedKey);
        } catch (_) {}
      }
    }
  }

  bool _shouldApply(RecurrentExpense expense, DateTime now, int effectiveDay) {
    if (now.day < effectiveDay) return false;

    // No aplicar si el gasto aún no ha comenzado (startDate en el futuro)
    final nowMonth = DateTime(now.year, now.month);
    final startMonth = DateTime(expense.startDate.year, expense.startDate.month);
    if (nowMonth.isBefore(startMonth)) return false;

    if (expense.lastApplied == null) return true;

    try {
      final parts = expense.lastApplied!.split('-');
      final lastMonth = int.parse(parts[0]);
      final lastYear = int.parse(parts[1]);

      // Si ya se aplicó este mismo mes y año, no duplicar
      if (lastMonth == now.month && lastYear == now.year) return false;

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
    } catch (_) {
      return true; // Si hay error en el formato, intentamos aplicar
    }
  }
}
