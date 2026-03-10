import 'package:ahorrapp/core/date/date.dart';
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
import 'package:ahorrapp/presentation/bloc/recurrent_expenses_cubit/recurrent_expenses_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

part 'debts_loans_state.dart';

class DebtsLoansCubit extends Cubit<DebtsLoansState> {
  final GetDebtsLoansUseCase getDebtsLoansUseCase;
  final AddDebtLoanUseCase addDebtLoanUseCase;
  final UpdateDebtLoanUseCase updateDebtLoanUseCase;
  final DeleteDebtLoanUseCase deleteDebtLoanUseCase;
  final RecurrentExpensesCubit recurrentExpensesCubit;

  DebtsLoansCubit({
    required this.getDebtsLoansUseCase,
    required this.addDebtLoanUseCase,
    required this.updateDebtLoanUseCase,
    required this.deleteDebtLoanUseCase,
    required this.recurrentExpensesCubit,
  }) : super(const DebtsLoansState());

  Future<void> loadDebtsLoans() async {
    emit(state.copyWith(isLoading: true));
    try {
      final items = await getDebtsLoansUseCase(Preferences.uId);
      emit(state.copyWith(debtsLoans: items, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> addOrUpdateDebtLoan({
    String? id,
    required String name,
    required String person,
    required double totalAmount,
    required DebtLoanType type,
    double paidAmount = 0.0,
    DateTime? date,
    DateTime? dueDate,
    bool isInstallment = false,
    int? totalInstallments,
    double? installmentAmount,
    bool addToRecurrent = false,
  }) async {
    emit(state.copyWith(isLoading: true));
    try {
      final isNew = id == null;
      final finalId = id ?? const Uuid().v4();
      
      String? recurrentId;
      
      if (addToRecurrent && isInstallment && installmentAmount != null) {
        recurrentId = const Uuid().v4();
        await recurrentExpensesCubit.addOrUpdateExpense(
          id: recurrentId,
          name: '$name ($person)',
          amount: installmentAmount,
          day: DateTime.now().day,
          category: 'deudas',
          frequency: RecurrentFrequency.monthly,
          startDate: DateTime.now(),
        );
      }

      final debtLoan = DebtLoan(
        id: finalId,
        userId: Preferences.uId,
        name: name,
        person: person,
        totalAmount: totalAmount,
        paidAmount: paidAmount,
        date: date,
        dueDate: dueDate,
        type: type,
        isInstallment: isInstallment,
        totalInstallments: totalInstallments,
        installmentAmount: installmentAmount,
        recurrentExpenseId: recurrentId,
        isCompleted: paidAmount >= totalAmount,
      );

      if (isNew) {
        await addDebtLoanUseCase(debtLoan);
      } else {
        await updateDebtLoanUseCase(debtLoan);
      }

      await loadDebtsLoans();
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> addPayment(String id, double amount, {bool addToHistory = false}) async {
    try {
      final debtLoan = state.debtsLoans.firstWhere((e) => e.id == id);
      final newPaidAmount = debtLoan.paidAmount + amount;
      final isCompleted = newPaidAmount >= debtLoan.totalAmount;
      
      final updatedDebtLoan = debtLoan.copyWith(
        paidAmount: newPaidAmount,
        isCompleted: isCompleted,
      );
      
      await updateDebtLoanUseCase(updatedDebtLoan);

      // Si el usuario lo solicita Y la deuda NO es a plazos, registramos el movimiento en el historial
      if (addToHistory && !debtLoan.isInstallment) {
        final date = Date();
        final isDebt = debtLoan.type == DebtLoanType.debt;
        
        final movement = Movement(
          id: const Uuid().v4(),
          name: debtLoan.name,
          amount: amount,
          type: isDebt ? MovementType.expense : MovementType.income,
          isIncome: !isDebt,
          date: date.currentDate(),
          hour: date.currentHour(),
          month: date.monthNames(),
          year: int.parse(date.year()),
          createdAt: DateTime.now(),
          category: 'deudas',
        );

        await getIt<SaveMovementUseCase>().call(movement);
      }

      await loadDebtsLoans();
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  /// Elimina deudas vinculadas a un gasto recurrente
  Future<void> deleteByRecurrentId(String recurrentId) async {
    try {
      final affectedDebts = state.debtsLoans.where((d) => d.recurrentExpenseId == recurrentId).toList();
      for (var debt in affectedDebts) {
        await deleteDebtLoanUseCase(debt.id);
      }
      if (affectedDebts.isNotEmpty) {
        await loadDebtsLoans();
      }
    } catch (_) {}
  }

  /// Limpia la referencia al gasto recurrente en cualquier deuda vinculada
  Future<void> clearRecurrentReference(String recurrentId) async {
    try {
      // Buscamos si hay alguna deuda que apunte a este ID recurrente
      final affectedDebts = state.debtsLoans.where((d) => d.recurrentExpenseId == recurrentId).toList();
      
      for (var debt in affectedDebts) {
        final updatedDebt = debt.copyWith(recurrentExpenseId: '');
        await updateDebtLoanUseCase(updatedDebt);
      }
      
      if (affectedDebts.isNotEmpty) {
        await loadDebtsLoans();
      }
    } catch (_) {}
  }

  Future<void> deleteDebtLoan(String id, {bool deleteRecurrent = false}) async {
    try {
      if (deleteRecurrent) {
        final debt = state.debtsLoans.firstWhere((d) => d.id == id);
        if (debt.recurrentExpenseId != null && debt.recurrentExpenseId!.isNotEmpty) {
          await recurrentExpensesCubit.deleteExpense(debt.recurrentExpenseId!);
        }
      }

      await deleteDebtLoanUseCase(id);
      await loadDebtsLoans();
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
