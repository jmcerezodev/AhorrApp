import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/domain/entities/movement.dart';
import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:ahorrapp/domain/usecases/recurrent_expenses/delete_recurrent_expense_usecase.dart';
import 'package:ahorrapp/domain/usecases/recurrent_expenses/get_recurrent_expenses_usecase.dart';
import 'package:ahorrapp/domain/usecases/recurrent_expenses/save_recurrent_expense_usecase.dart';
import 'package:ahorrapp/domain/usecases/save_movement_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

part 'recurrent_expenses_state.dart';

class RecurrentExpensesCubit extends Cubit<RecurrentExpensesState> {
  final GetRecurrentExpensesUseCase _getRecurrentExpensesUseCase = getIt<GetRecurrentExpensesUseCase>();
  final SaveRecurrentExpenseUseCase _saveRecurrentExpenseUseCase = getIt<SaveRecurrentExpenseUseCase>();
  final DeleteRecurrentExpenseUseCase _deleteRecurrentExpenseUseCase = getIt<DeleteRecurrentExpenseUseCase>();
  final SaveMovementUseCase _saveMovementUseCase = getIt<SaveMovementUseCase>();

  RecurrentExpensesCubit() : super(const RecurrentExpensesState());

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

  Future<void> addOrUpdateExpense({
    String? id,
    required String name,
    required double amount,
    int? day,
    String category = 'general',
    bool isActive = true,
    RecurrentFrequency frequency = RecurrentFrequency.monthly,
    DateTime? startDate,
    int? position, // AÑADIDO
  }) async {
    emit(state.copyWith(status: RecurrentExpensesStatus.loading));
    
    String? lastApplied;
    DateTime finalStartDate = startDate ?? DateTime.now();
    int finalPosition = position ?? 0; // Valor por defecto

    if (id != null) {
      final currentExpense = state.expenses.cast<RecurrentExpense?>().firstWhere(
        (e) => e?.id == id, 
        orElse: () => null
      );
      lastApplied = currentExpense?.lastApplied;
      if (startDate == null && currentExpense != null) {
        finalStartDate = currentExpense.startDate;
      }
      if (position == null && currentExpense != null) {
        finalPosition = currentExpense.position;
      }
    } else {
      // Si es nuevo, lo ponemos al final de la lista
      finalPosition = state.expenses.length;
    }

    final expense = RecurrentExpense(
      id: id ?? const Uuid().v4(),
      userId: Preferences.uId,
      name: name,
      amount: amount,
      day: day,
      category: category,
      isActive: isActive,
      lastApplied: lastApplied,
      frequency: frequency,
      startDate: finalStartDate,
      position: finalPosition, // AÑADIDO
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

  Future<void> reorderExpenses(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final List<RecurrentExpense> items = List.from(state.expenses);
    final RecurrentExpense item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    // Actualizamos las posiciones localmente de forma optimista
    final List<RecurrentExpense> updatedItems = [];
    for (int i = 0; i < items.length; i++) {
      updatedItems.add(items[i].copyWith(position: i));
    }

    emit(state.copyWith(expenses: updatedItems));

    // Persistimos los cambios
    try {
      for (var expense in updatedItems) {
        await _saveRecurrentExpenseUseCase(expense);
      }
    } catch (e) {
      // Si falla la persistencia, recargamos para volver al estado anterior
      await loadExpenses();
    }
  }

  Future<void> applyExpenseManually(RecurrentExpense expense) async {
    final dateService = Date();
    
    final movement = Movement(
      id: const Uuid().v4(),
      name: expense.name,
      amount: expense.amount,
      type: MovementType.expense,
      isIncome: false,
      date: dateService.currentDate(),
      hour: dateService.currentHour(),
      month: dateService.monthNames(),
      year: int.parse(dateService.year()),
      createdAt: DateTime.now(),
    );

    try {
      await _saveMovementUseCase(movement);
    } catch (e) {
      emit(state.copyWith(
        status: RecurrentExpensesStatus.failure,
        errorMessage: 'Error al añadir el gasto: $e',
      ));
    }
  }

  Future<void> deleteExpense(String id) async {
    emit(state.copyWith(status: RecurrentExpensesStatus.loading));
    try {
      await _deleteRecurrentExpenseUseCase(id);
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
      position: expense.position, // AÑADIDO
    );
  }
}
