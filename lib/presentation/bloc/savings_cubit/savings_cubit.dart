import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/inputs/inputs.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/data/local/models/local_history.dart';
import 'package:ahorrapp/domain/entities/movement.dart';
import 'package:ahorrapp/domain/usecases/save_movement_usecase.dart';
import 'package:ahorrapp/presentation/bloc/history_cubit/history_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:uuid/uuid.dart';

part 'savings_cubit_state.dart';

class SavingsCubit extends Cubit<SavingsCubitState> {
  final AppwriteRepository _repository = getIt<AppwriteRepository>();
  final LocalDbService _localDb = getIt<LocalDbService>();
  final SaveMovementUseCase _saveMovementUseCase = getIt<SaveMovementUseCase>();

  SavingsCubit() : super(const SavingsCubitState()) {
    if (Preferences.uId.isNotEmpty) {
      loadSavings();
    }
  }

  Future<void> loadSavings() async {
    emit(state.copyWith(formStatus: FormStatusSavings.validating));
    try {
      final String uid = Preferences.uId;
      final double goal = await _localDb.getSavingGoal(uid);
      final double total = await _localDb.calculateTotalSavings(uid);
      
      emit(state.copyWith(
        savingGoal: goal,
        savingTotal: total,
        formStatus: FormStatusSavings.valid
      ));
    } catch (e) {
      emit(state.copyWith(formStatus: FormStatusSavings.invalid));
    }
  }

  Future<void> addSaving(HistoryCubit historyCubit, {double? customAmount, String? customName}) async {
    final double amount = customAmount ?? double.parse(state.saving.value.replaceAll(',', '.'));
    final String name = customName ?? 'Aportación de ahorro';

    emit(state.copyWith(formStatus: FormStatusSavings.validating));

    final date = Date();
    final String month = date.monthNames();
    final int year = int.parse(date.year());
    final String tempId = const Uuid().v4();

    final movement = Movement(
      id: tempId,
      name: name,
      amount: amount,
      type: MovementType.saving,
      isIncome: false,
      date: date.currentDate(),
      hour: date.currentHour(),
      month: month,
      year: year,
      createdAt: DateTime.now(),
    );

    try {
      await _saveMovementUseCase(movement);
      await loadSavings();
      await historyCubit.loadHistoryByDate(month, year);
      emit(state.copyWith(formStatus: FormStatusSavings.valid));
    } catch (e) {
      emit(state.copyWith(formStatus: FormStatusSavings.invalid));
    }
  }

  Future<void> emptySavings(HistoryCubit historyCubit) async {
    emit(state.copyWith(formStatus: FormStatusSavings.validating));
    try {
      final List<String> appwriteIds = await _localDb.markSavingsAsSpent();
      for (var id in appwriteIds) {
        await _repository.updateSaving(documentId: id, data: {'isSpent': true});
      }
      await loadSavings();
      final date = Date();
      await historyCubit.loadHistoryByDate(date.monthNames(), int.parse(date.year()));
      emit(state.copyWith(formStatus: FormStatusSavings.valid));
    } catch (e) {
      emit(state.copyWith(formStatus: FormStatusSavings.invalid));
    }
  }

  Future<void> removeContribution(String id) async {
    try {
      await _repository.deleteSaving(id);
      await _localDb.deleteItemByAppwriteId(id);
      await loadSavings();
    } catch (e) {
      emit(state.copyWith(formStatus: FormStatusSavings.invalid));
    }
  }

  Future<void> setGoal(double value) async {
    final String uid = Preferences.uId;
    await _localDb.saveSavingGoal(uid, value);
    await _repository.updatePrefs({'savingGoal': value});
    emit(state.copyWith(savingGoal: value));
  }

  void resetCubit() {
    emit(state.copyWith(saving: const SavingInput.pure()));
  }

  void savingChanged(String value) {
    final saving = SavingInput.dirty(value: value);
    emit(state.copyWith(saving: saving, isValid: Formz.validate([saving])));
  }
}
