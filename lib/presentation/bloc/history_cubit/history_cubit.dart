import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/core/inputs/inputs.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/data/local/models/local_history.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

part 'history_cubit_state.dart';

class HistoryCubit extends Cubit<HistoryCubitState> {
  final AppwriteRepository _repository = AppwriteRepository();
  final LocalDbService _localDb = LocalDbService();
  final TotalMoneyCubit totalMoneyCubit;

  HistoryCubit({required this.totalMoneyCubit}) : super(const HistoryCubitState());

  Future<void> loadHistory() async {
    final date = Date();
    await loadHistoryByDate(date.monthNames(), int.parse(date.year()));
  }

  Future<void> forceBalanceResync() async {
    emit(state.copyWith(isSyncing: true, syncProgress: 0.0));
    try {
      await _localDb.clearAll();
      final fullData = await _repository.syncFullData(
        Preferences.uId, 
        (progress) => emit(state.copyWith(syncProgress: progress))
      );
      final List<LocalHistory> localItems = _convertToLocal(fullData['history'], fullData['savings']);
      await _localDb.saveHistoryItems(localItems);
      await _localDb.saveSavingGoal(Preferences.uId, fullData['savingGoal']);
      final double correctBalance = fullData['balance'];
      await _localDb.saveTotalBalance(Preferences.uId, correctBalance);
      totalMoneyCubit.totalMoney(correctBalance);
      emit(state.copyWith(isSyncing: false, syncProgress: 1.0));
      final date = Date();
      await loadHistoryByDate(date.monthNames(), int.parse(date.year()));
    } catch (e) {
      emit(state.copyWith(isSyncing: false));
    }
  }

  Future<void> loadHistoryByDate(String month, int year) async {
    if (year == 0) return;
    emit(state.copyWith(formStatus: FormStatusHistory.validating));
    try {
      final localTotalCount = await _localDb.getTotalCount();
      double globalBalance = await _localDb.getTotalBalance(Preferences.uId);
      if (localTotalCount == 0) {
        await forceBalanceResync();
        return;
      }
      totalMoneyCubit.totalMoney(globalBalance);
      final localData = await _localDb.getHistoryByMonth(month, year);
      final List<Map<String, dynamic>> uiList = localData.map((e) => {
        'id': e.appwriteId,
        'name': e.name,
        'money': e.money,
        'type': e.type,
        'isIncome': e.isIncome,
        'currentDate': e.currentDate,
        'currentHour': e.currentHour,
        'month': e.month,
        'year': e.year,
        'createdAt': e.createdAt.toIso8601String(),
      }).toList();
      emit(state.copyWith(historyList: uiList, formStatus: FormStatusHistory.valid));
    } catch (e) {
      emit(state.copyWith(formStatus: FormStatusHistory.invalid, isSyncing: false));
    }
  }

  // --- ACCIONES CRUD OPTIMIZADAS ---

  // 1. AÑADIR (Suma/Resta importe total)
  Future<void> addMovementLocally(LocalHistory item) async {
    await _localDb.saveHistoryItems([item]);
    if (item.type != 'saving') {
      await _updateBalance(item.money, item.type == 'income');
    }
    await loadHistoryByDate(item.month, item.year);
  }

  // 2. ACTUALIZAR (Calcula diferencia y ajusta balance)
  Future<void> updateMovementLocally(LocalHistory item, double oldAmount) async {
    await _localDb.saveHistoryItems([item]);
    if (item.type != 'saving') {
      final double diff = item.type == 'income' ? (item.money - oldAmount) : (oldAmount - item.money);
      if (diff != 0) {
        await _updateBalance(diff.abs(), diff > 0);
      }
    }
    await loadHistoryByDate(item.month, item.year);
  }

  // 3. ELIMINAR (Revierte la operación original)
  Future<void> deleteMovementLocally(String appwriteId, String month, int year, double amount, String type) async {
    await _localDb.deleteItemByAppwriteId(appwriteId);
    if (type != 'saving') {
      // Si borramos un ingreso restamos, si borramos un gasto sumamos
      await _updateBalance(amount, type == 'expense');
    }
    await loadHistoryByDate(month, year);
  }

  // Método privado para evitar duplicidad de lógica de balance
  Future<void> _updateBalance(double amount, bool isAddition) async {
    double current = await _localDb.getTotalBalance(Preferences.uId);
    final double newBalance = isAddition ? current + amount : current - amount;
    await _localDb.saveTotalBalance(Preferences.uId, newBalance);
    await _repository.updateTotalBalance(newBalance);
    totalMoneyCubit.totalMoney(newBalance);
  }

  List<LocalHistory> _convertToLocal(dynamic historyDocs, dynamic savingsDocs) {
    final List<LocalHistory> results = [];
    for (var doc in (historyDocs as List)) {
      results.add(LocalHistory()
        ..appwriteId = doc.$id
        ..name = doc.data['name'] ?? 'Sin nombre'
        ..money = (doc.data['money'] as num).toDouble()
        ..type = (doc.data['isIncome'] == true) ? 'income' : 'expense'
        ..isIncome = doc.data['isIncome'] ?? false
        ..currentDate = doc.data['currentDate'] ?? ''
        ..currentHour = doc.data['currentHour'] ?? ''
        ..month = doc.data['month']?.toString() ?? ''
        ..year = int.tryParse(doc.data['year']?.toString() ?? '0') ?? 0
        ..createdAt = DateTime.parse(doc.$createdAt)
      );
    }
    for (var doc in (savingsDocs as List)) {
      final DateTime date = DateTime.parse(doc.$createdAt);
      results.add(LocalHistory()
        ..appwriteId = doc.$id
        ..name = doc.data['description'] ?? 'Ahorro'
        ..money = (doc.data['money'] as num).toDouble()
        ..type = 'saving'
        ..isIncome = false
        ..currentDate = "${date.day}/${date.month}/${date.year}"
        ..currentHour = "${date.hour}:${date.minute}"
        ..month = doc.data['month'] ?? ''
        ..year = doc.data['year'] ?? 0
        ..createdAt = date
      );
    }
    return results;
  }

  void toggleIncomes(bool value) => emit(state.copyWith(showIncomes: value));
  void toggleExpenses(bool value) => emit(state.copyWith(showExpenses: value));
  void toggleSavings(bool value) => emit(state.copyWith(showSavings: value));
  void toggleFilterPanel() => emit(state.copyWith(isFilterOpen: !state.isFilterOpen));
  void listOrder(String value) => emit(state.copyWith(listOrder: value));
  void isChart(bool value) => emit(state.copyWith(isChart: value));
  void resetCubit() => emit(state.copyWith(newName: const IncomeNameInput.pure(), newMoney: const IncomeMoneyInput.pure(), formStatus: FormStatusHistory.invalid));
  void newNameChanged(String value) { final newName = IncomeNameInput.dirty(value: value); emit(state.copyWith(newName: newName, isValid: Formz.validate([newName, state.newMoney]))); }
  void newMoneyChanged(String value) { final newMoney = IncomeMoneyInput.dirty(value: value); emit(state.copyWith(newMoney: newMoney, isValid: Formz.validate([newMoney, state.newName]))); }
}
