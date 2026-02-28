import 'package:ahorrapp/core/inputs/inputs.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

part 'savings_cubit_state.dart';

class SavingsCubit extends Cubit<SavingsCubitState> {
  final AppwriteRepository _repository = AppwriteRepository();

  SavingsCubit() : super(SavingsCubitState(
    savingGoal: Preferences.savingGoal // Cargamos la meta persistente al iniciar
  )) {
    if (Preferences.uId.isNotEmpty) {
      loadSavings();
    }
  }

  // CARGAR AHORROS DESDE APPWRITE
  Future<void> loadSavings() async {
    emit(state.copyWhith(formStatus: FormStatusSavings.validating));
    try {
      final documents = await _repository.getSavings(Preferences.uId);
      
      final List<Map<String, dynamic>> savings = documents.map((doc) {
        return {
          'id': doc.$id,
          'money': doc.data['money'],
          'description': doc.data['description'],
          'createdAt': doc.$createdAt,
        };
      }).toList();

      // Calcular el total sumando todas las aportaciones
      double total = 0;
      for (var s in savings) {
        total += (s['money'] as num).toDouble();
      }

      emit(state.copyWhith(
        savingsList: savings,
        savingTotal: total,
        formStatus: FormStatusSavings.valid
      ));
    } catch (e) {
      emit(state.copyWhith(formStatus: FormStatusSavings.invalid));
    }
  }

  // AÑADIR NUEVA APORTACIÓN
  Future<void> addContribution() async {
    final double? value = double.tryParse(state.saving.value.replaceAll(',', '.'));
    if (value == null) return;

    emit(state.copyWhith(formStatus: FormStatusSavings.validating));
    try {
      await _repository.addSaving(
        userId: Preferences.uId,
        money: value,
      );
      await loadSavings(); // Recargamos para actualizar lista y total
    } catch (e) {
      emit(state.copyWhith(formStatus: FormStatusSavings.invalid));
    }
  }

  // ELIMINAR UNA APORTACIÓN ESPECÍFICA
  Future<void> removeContribution(String id) async {
    try {
      await _repository.deleteSaving(id);
      await loadSavings();
    } catch (e) {
      emit(state.copyWhith(formStatus: FormStatusSavings.invalid));
    }
  }

  // REINICIAR TODO (BORRADO TOTAL)
  Future<void> deleteSavings() async {
    emit(state.copyWhith(formStatus: FormStatusSavings.validating));
    try {
      await _repository.deleteAllSavings(Preferences.uId);
      await loadSavings();
    } catch (e) {
      emit(state.copyWhith(formStatus: FormStatusSavings.invalid));
    }
  }

  void setGoal(double value) {
    // Guardamos en preferencias para persistencia entre sesiones
    Preferences.savingGoal = value;
    emit(state.copyWhith(savingGoal: value));
  }

  void resetCubit() {
    emit(state.copyWhith(saving: const SavingInput.pure()));
  }

  void savingChanged(String value) {
    final saving = SavingInput.dirty(value: value);
    emit(state.copyWhith(
      saving: saving,
      isValid: Formz.validate([saving]),
    ));
  }
}
