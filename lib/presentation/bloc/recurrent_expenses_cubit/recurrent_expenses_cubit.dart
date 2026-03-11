import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/domain/entities/movement.dart';
import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:ahorrapp/domain/usecases/recurrent_expenses/delete_recurrent_expense_usecase.dart';
import 'package:ahorrapp/domain/usecases/recurrent_expenses/get_recurrent_expenses_usecase.dart';
import 'package:ahorrapp/domain/usecases/recurrent_expenses/save_recurrent_expense_usecase.dart';
import 'package:ahorrapp/domain/usecases/save_movement_usecase.dart';
import 'package:ahorrapp/presentation/bloc/debts_loans_cubit/debts_loans_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

part 'recurrent_expenses_state.dart';

class RecurrentExpensesCubit extends Cubit<RecurrentExpensesState> {
  final GetRecurrentExpensesUseCase _getRecurrentExpensesUseCase = getIt<GetRecurrentExpensesUseCase>();
  final SaveRecurrentExpenseUseCase _saveRecurrentExpenseUseCase = getIt<SaveRecurrentExpenseUseCase>();
  final DeleteRecurrentExpenseUseCase _deleteRecurrentExpenseUseCase = getIt<DeleteRecurrentExpenseUseCase>();
  final SaveMovementUseCase _saveMovementUseCase = getIt<SaveMovementUseCase>();

  RecurrentExpensesCubit() : super(RecurrentExpensesState(
    showProrated: Preferences.isProratedView,
  ));

  Future<void> loadExpenses() async {
    emit(state.copyWith(status: RecurrentExpensesStatus.loading));
    try {
      final expenses = await _getRecurrentExpensesUseCase(Preferences.uId);
      emit(state.copyWith(
        expenses: expenses,
        status: RecurrentExpensesStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RecurrentExpensesStatus.failure,
        errorMessage: 'Error al cargar: $e',
      ));
    }
  }

  void toggleProratedView() {
    final newValue = !state.showProrated;
    Preferences.isProratedView = newValue;
    emit(state.copyWith(showProrated: newValue));
  }

  void toggleFilterPanel() {
    emit(state.copyWith(isFilterOpen: !state.isFilterOpen));
  }

  void toggleAutomaticFilter(bool value) {
    emit(state.copyWith(showAutomatic: value));
  }

  void toggleManualFilter(bool value) {
    emit(state.copyWith(showManual: value));
  }

  void toggleCategoryFilter(String category) {
    final currentSelected = List<String>.from(state.selectedCategories);
    if (currentSelected.contains(category)) {
      currentSelected.remove(category);
    } else {
      currentSelected.add(category);
    }
    emit(state.copyWith(selectedCategories: currentSelected));
  }

  Future<void> addOrUpdateExpense({
    String? id,
    required String name,
    required double amount,
    int? day,
    String category = 'general',
    bool? isActive, 
    RecurrentFrequency frequency = RecurrentFrequency.monthly,
    DateTime? startDate,
    int? position,
    bool? includeInSummary, 
    bool isIncome = false,
  }) async {
    emit(state.copyWith(status: RecurrentExpensesStatus.loading));
    
    String? lastApplied;
    DateTime finalStartDate = startDate ?? DateTime.now();
    int finalPosition = position ?? 0;
    bool finalIsActive = isActive ?? true;
    bool finalIncludeInSummary = includeInSummary ?? true;

    if (id != null) {
      final currentExpense = state.expenses.cast<RecurrentExpense?>().firstWhere(
        (e) => e?.id == id, 
        orElse: () => null
      );
      
      if (currentExpense != null) {
        lastApplied = currentExpense.lastApplied;
        if (startDate == null) finalStartDate = currentExpense.startDate;
        if (position == null) finalPosition = currentExpense.position;
        if (isActive == null) finalIsActive = currentExpense.isActive;
        if (includeInSummary == null) finalIncludeInSummary = currentExpense.includeInSummary;
      }
    } else {
      finalPosition = position ?? state.expenses.length;
    }

    final expense = RecurrentExpense(
      id: id ?? const Uuid().v4(),
      userId: Preferences.uId,
      name: name,
      amount: amount,
      day: day,
      category: category,
      isActive: finalIsActive,
      lastApplied: lastApplied,
      frequency: frequency,
      startDate: finalStartDate,
      position: finalPosition,
      includeInSummary: finalIncludeInSummary,
      isIncome: isIncome,
    );

    try {
      await _saveRecurrentExpenseUseCase(expense);
      await loadExpenses();
    } catch (e) {
      emit(state.copyWith(
        status: RecurrentExpensesStatus.failure,
        errorMessage: 'Error técnico al guardar: $e',
      ));
    }
  }

  Future<void> reorderExpenses(int oldIndex, int newIndex, {required bool isIncome}) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final List<RecurrentExpense> allItems = List.from(state.expenses);
    final List<RecurrentExpense> typeItems = allItems.where((e) => e.isIncome == isIncome).toList();
    
    final RecurrentExpense itemToMove = typeItems.removeAt(oldIndex);
    typeItems.insert(newIndex, itemToMove);

    for (int i = 0; i < typeItems.length; i++) {
      final updatedItem = typeItems[i].copyWith(position: i);
      final indexInGlobal = allItems.indexWhere((e) => e.id == updatedItem.id);
      allItems[indexInGlobal] = updatedItem;
    }

    emit(state.copyWith(expenses: allItems));

    try {
      for (var expense in typeItems) {
        await _saveRecurrentExpenseUseCase(expense);
      }
    } catch (e) {
      await loadExpenses();
    }
  }

  Future<void> applyExpenseManually(RecurrentExpense expense, {DebtsLoansCubit? debtsCubit}) async {
    final dateService = Date();
    
    final movement = Movement(
      id: const Uuid().v4(),
      name: expense.name,
      amount: expense.amount,
      type: expense.isIncome ? MovementType.income : MovementType.expense,
      isIncome: expense.isIncome,
      date: dateService.currentDate(),
      hour: dateService.currentHour(),
      month: dateService.monthNames(),
      year: int.parse(dateService.year()),
      createdAt: DateTime.now(),
      isRecurrent: true,
    );

    try {
      await _saveMovementUseCase(movement);

      // CORRECCIÓN: Si hay un cubit de deudas, actualizamos el progreso del registro vinculado (venga de deuda o préstamo)
      if (debtsCubit != null) {
        final linkedItem = debtsCubit.state.debtsLoans.where((d) => d.recurrentExpenseId == expense.id).firstOrNull;
        if (linkedItem != null) {
          await debtsCubit.addPayment(linkedItem.id, expense.amount, addToHistory: false);
        }
      }
    } catch (e) {
      emit(state.copyWith(
        status: RecurrentExpensesStatus.failure,
        errorMessage: 'Error al añadir el registro: $e',
      ));
    }
  }

  Future<void> deleteExpense(String id, {DebtsLoansCubit? debtsCubit, bool deleteDebt = false}) async {
    emit(state.copyWith(status: RecurrentExpensesStatus.loading));
    try {
      await _deleteRecurrentExpenseUseCase(id);
      
      if (deleteDebt && debtsCubit != null) {
        await debtsCubit.deleteByRecurrentId(id);
      } 
      else if (debtsCubit != null) {
        await debtsCubit.clearRecurrentReference(id);
      }

      await loadExpenses();
    } catch (e) {
      emit(state.copyWith(
        status: RecurrentExpensesStatus.failure,
        errorMessage: 'Error al eliminar: $e',
      ));
    }
  }

  Future<void> toggleActive(RecurrentExpense expense) async {
    await addOrUpdateExpense(
      id: expense.id,
      name: expense.name,
      amount: expense.amount,
      day: expense.day,
      category: expense.category,
      isActive: !expense.isActive,
      frequency: expense.frequency,
      startDate: expense.startDate,
      position: expense.position,
      includeInSummary: expense.includeInSummary,
      isIncome: expense.isIncome,
    );
  }
}
