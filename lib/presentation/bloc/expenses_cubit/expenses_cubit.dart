import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/inputs/inputs.dart';
import 'package:ahorrapp/domain/entities/movement.dart';
import 'package:ahorrapp/domain/usecases/save_movement_usecase.dart';
import 'package:ahorrapp/presentation/bloc/history_cubit/history_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:uuid/uuid.dart';

part 'expenses_cubit_state.dart';

class ExpensesCubit extends Cubit<ExpensesCubitState> {
  final SaveMovementUseCase _saveMovementUseCase = getIt<SaveMovementUseCase>();

  ExpensesCubit() : super(const ExpensesCubitState());

  Future<void> saveExpense(HistoryCubit historyCubit) async {
    if (!state.isValid) return;

    emit(state.copyWith(status: ExpensesStatus.posting));

    final date = Date();
    final double amount = double.parse(state.expenseMoney.value.replaceAll(',', '.'));
    final String month = date.monthNames();
    final int year = int.parse(date.year());
    
    final String tempId = const Uuid().v4();

    final movement = Movement(
      id: tempId,
      name: state.expenseName.value,
      amount: amount,
      type: MovementType.expense,
      isIncome: false,
      date: date.currentDate(),
      hour: date.currentHour(),
      month: month,
      year: year,
      createdAt: DateTime.now(),
    );

    try {
      await _saveMovementUseCase(movement);
      await historyCubit.loadHistoryByDate(month, year);
      emit(state.copyWith(status: ExpensesStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: ExpensesStatus.failure,
        errorMessage: 'Error al registrar el gasto: $e',
      ));
    }
  }

  void resetCubit() {
    emit(const ExpensesCubitState());
  }

  void expenseNameChanged(String value) {
    final expenseName = ExpenseNameInput.dirty(value: value);
    emit(state.copyWith(
      expenseName: expenseName,
      isValid: Formz.validate([expenseName, state.expenseMoney]),
      status: ExpensesStatus.initial,
    ));
  }

  void expenseMoneyChanged(String value) {
    final expenseMoney = ExpenseMoneyInput.dirty(value: value);
    emit(state.copyWith(
      expenseMoney: expenseMoney,
      isValid: Formz.validate([expenseMoney, state.expenseName]),
      status: ExpensesStatus.initial,
    ));
  }
}
