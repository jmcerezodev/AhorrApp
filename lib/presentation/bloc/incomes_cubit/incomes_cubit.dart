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

part 'incomes_cubit_state.dart';

class IncomesCubit extends Cubit<IncomesCubitState> {
  final SaveMovementUseCase _saveMovementUseCase = getIt<SaveMovementUseCase>();

  IncomesCubit() : super(const IncomesCubitState());

  Future<void> saveIncome(HistoryCubit historyCubit) async {
    if (!state.isValid) return;

    emit(state.copyWith(status: IncomesStatus.posting));

    final date = Date();
    final double amount = double.parse(state.incomeMoney.value.replaceAll(',', '.'));
    final String month = date.monthNames();
    final int year = int.parse(date.year());
    
    final String tempId = const Uuid().v4();

    final movement = Movement(
      id: tempId,
      name: state.incomeName.value,
      amount: amount,
      type: MovementType.income,
      isIncome: true,
      date: date.currentDate(),
      hour: date.currentHour(),
      month: month,
      year: year,
      createdAt: DateTime.now(),
      category: state.category, // AÑADIDO
    );

    try {
      await _saveMovementUseCase(movement);
      await historyCubit.loadHistoryByDate(month, year);
      emit(state.copyWith(status: IncomesStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: IncomesStatus.failure,
        errorMessage: 'Error al conectar con el servidor: $e',
      ));
    }
  }

  void resetCubit() {
    emit(const IncomesCubitState());
  }

  void categoryChanged(String value) { // NUEVO
    emit(state.copyWith(category: value));
  }

  void incomeNameChanged(String value) {
    final incomeName = IncomeNameInput.dirty(value: value);
    emit(state.copyWith(
      incomeName: incomeName,
      isValid: Formz.validate([incomeName, state.incomeMoney]),
      status: IncomesStatus.initial,
    ));
  }

  void incomeMoneyChanged(String value) {
    final incomeMoney = IncomeMoneyInput.dirty(value: value);
    emit(state.copyWith(
      incomeMoney: incomeMoney,
      isValid: Formz.validate([incomeMoney, state.incomeName]),
      status: IncomesStatus.initial,
    ));
  }
}
