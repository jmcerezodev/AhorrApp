import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/inputs/inputs.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
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
    // No emitimos loading aquí si ya tenemos datos para evitar parpadeos innecesarios en el login
    try {
      final String uid = Preferences.uId;
      if (uid.isEmpty) return;

      final double goal = await _localDb.getSavingGoal(uid);
      final double total = await _localDb.calculateTotalSavings(uid);
      
      emit(state.copyWith(
        savingGoal: goal,
        savingTotal: total,
        status: SavingsStatus.success
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SavingsStatus.failure,
        errorMessage: 'Error al cargar ahorros: $e'
      ));
    }
  }

  // Nuevo método explícito para reiniciar y cargar
  Future<void> refresh() async {
    await loadSavings();
  }

  Future<void> addSaving(HistoryCubit historyCubit, {double? customAmount, String? customName}) async {
    final double? amount = customAmount ?? double.tryParse(state.saving.value.replaceAll(',', '.'));
    if (amount == null) return;
    
    final String name = customName ?? 'Aportación de ahorro';

    emit(state.copyWith(status: SavingsStatus.loading));

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
      emit(state.copyWith(status: SavingsStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: SavingsStatus.failure,
        errorMessage: 'Error al añadir ahorro: $e'
      ));
    }
  }

  Future<void> emptySavings(HistoryCubit historyCubit) async {
    emit(state.copyWith(status: SavingsStatus.loading));
    
    try {
      final List<String> appwriteIds = await _localDb.markSavingsAsSpent();
      
      for (final id in appwriteIds) {
        try {
          await _repository.updateSaving(documentId: id, data: {'isSpent': true});
        } catch (_) {
          await _localDb.addPendingSync(
            'update', 
            'savings', 
            {'isSpent': true}, 
            appwriteId: id
          );
        }
      }

      await loadSavings();
      final date = Date();
      await historyCubit.loadHistoryByDate(date.monthNames(), int.parse(date.year()));
      
      emit(state.copyWith(status: SavingsStatus.success));

    } catch (e) {
      emit(state.copyWith(
        status: SavingsStatus.failure,
        errorMessage: 'Error al vaciar ahorros: $e'
      ));
    }
  }

  Future<void> removeContribution(String id) async {
    emit(state.copyWith(status: SavingsStatus.loading));
    try {
      try {
        await _repository.deleteSaving(id);
      } catch (_) {
        await _localDb.addPendingSync('delete', 'savings', {}, appwriteId: id);
      }

      await _localDb.deleteItemByAppwriteId(id);
      await loadSavings();
      emit(state.copyWith(status: SavingsStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: SavingsStatus.failure,
        errorMessage: 'Error al eliminar contribución: $e'
      ));
    }
  }

  Future<void> setGoal(double value) async {
    emit(state.copyWith(status: SavingsStatus.loading));
    try {
      final String uid = Preferences.uId;
      await _localDb.saveSavingGoal(uid, value);
      
      try {
        await _repository.updatePrefs({'savingGoal': value});
      } catch (_) {
        await _localDb.addPendingSync(
          'update_goal', 
          'settings', 
          {'savingGoal': value}
        );
      }

      emit(state.copyWith(savingGoal: value, status: SavingsStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: SavingsStatus.failure,
        errorMessage: 'Error al establecer meta: $e'
      ));
    }
  }

  void resetCubit() {
    emit(const SavingsCubitState());
  }

  void savingChanged(String value) {
    final saving = SavingInput.dirty(value: value);
    emit(state.copyWith(
      saving: saving, 
      isValid: Formz.validate([saving]),
      status: SavingsStatus.initial
    ));
  }
}
