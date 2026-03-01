import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/core/inputs/inputs.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/data/local/models/local_history.dart';
import 'package:ahorrapp/presentation/bloc/history_cubit/history_cubit.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

part 'savings_cubit_state.dart';

class SavingsCubit extends Cubit<SavingsCubitState> {
  final AppwriteRepository _repository = AppwriteRepository();
  final LocalDbService _localDb = LocalDbService();

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

  Future<void> addContribution() async {
    final double? value = double.tryParse(state.saving.value.replaceAll(',', '.'));
    if (value == null) return;

    final date = Date();
    final String month = date.monthNames();
    final int year = int.parse(date.year());

    emit(state.copyWith(formStatus: FormStatusSavings.validating));
    try {
      final doc = await _repository.addSaving(
        userId: Preferences.uId,
        money: value,
        month: month,
        year: year,
      );

      await _localDb.saveHistoryItems([
        LocalHistory()
          ..appwriteId = doc.$id
          ..name = 'Aportación de ahorro'
          ..money = value
          ..type = 'saving'
          ..isIncome = false
          ..currentDate = date.currentDate()
          ..currentHour = date.currentHour()
          ..month = month
          ..year = year
          ..createdAt = DateTime.parse(doc.$createdAt)
          ..isSpent = false
      ]);

      await loadSavings();
    } catch (e) {
      emit(state.copyWith(formStatus: FormStatusSavings.invalid));
    }
  }

  Future<void> emptySavings(HistoryCubit historyCubit) async {
    emit(state.copyWith(formStatus: FormStatusSavings.validating));
    try {
      // 1. Marcamos localmente en Isar como gastados
      final List<String> appwriteIds = await _localDb.markSavingsAsSpent();
      
      // 2. Sincronizamos con Appwrite (Colección savingsList)
      for (var id in appwriteIds) {
        // CORRECCIÓN: Actualizamos el campo isSpent en la nube
        await _repository.updateSaving(documentId: id, data: {'isSpent': true});
      }

      // 3. Recargamos datos para actualizar UI
      await loadSavings();
      final date = Date();
      await historyCubit.loadHistoryByDate(date.monthNames(), int.parse(date.year()));
      
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
