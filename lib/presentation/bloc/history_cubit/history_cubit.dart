import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/inputs/inputs.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/data/local/models/local_history.dart';
import 'package:ahorrapp/data/local/models/local_saving.dart';
import 'package:ahorrapp/domain/usecases/get_movements_usecase.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:isar/isar.dart';

part 'history_cubit_state.dart';

class HistoryCubit extends Cubit<HistoryCubitState> {
  final GetMovementsUseCase _getMovementsUseCase = getIt<GetMovementsUseCase>();
  final AppwriteRepository _repository = getIt<AppwriteRepository>();
  final LocalDbService _localDb = getIt<LocalDbService>();
  final TotalMoneyCubit totalMoneyCubit;

  HistoryCubit({required this.totalMoneyCubit}) : super(const HistoryCubitState());

  Future<void> loadHistory() async {
    final date = Date();
    await loadHistoryByDate(date.monthNames(), int.parse(date.year()));
  }

  Future<void> forceBalanceResync(TotalMoneyCubit totalMoneyCubit) async {
    emit(state.copyWith(status: HistoryStatus.loading, isSyncing: true, syncProgress: 0.0));
    try {
      await _localDb.clearAll();
      final fullData = await _repository.syncFullData(
        Preferences.uId, 
        (progress) => emit(state.copyWith(syncProgress: progress))
      );
      
      // Procesamos historial
      final List<LocalHistory> historyItems = _convertToLocalHistory(fullData['history']);
      await _localDb.saveHistoryItems(historyItems);
      
      // Procesamos ahorros
      final List<LocalSaving> savingItems = _convertToLocalSaving(fullData['savings']);
      await _localDb.saveSavingItems(savingItems);

      await _localDb.saveSavingGoal(Preferences.uId, fullData['savingGoal']);
      final double correctBalance = fullData['balance'];
      await _localDb.saveTotalBalance(Preferences.uId, correctBalance);
      totalMoneyCubit.totalMoney(correctBalance);
      
      emit(state.copyWith(isSyncing: false, syncProgress: 1.0, status: HistoryStatus.success));
      final date = Date();
      await loadHistoryByDate(date.monthNames(), int.parse(date.year()));
    } catch (e) {
      emit(state.copyWith(isSyncing: false, status: HistoryStatus.failure));
    }
  }

  Future<void> loadHistoryByDate(String month, int year) async {
    if (year == 0) return;
    emit(state.copyWith(status: HistoryStatus.loading));
    try {
      final localTotalCount = await _localDb.getTotalCount();
      double globalBalance = await _localDb.getTotalBalance(Preferences.uId);
      
      if (localTotalCount == 0) {
        await forceBalanceResync(totalMoneyCubit);
        return;
      }
      
      totalMoneyCubit.totalMoney(globalBalance);
      final movements = await _getMovementsUseCase(Preferences.uId, month, year);
      
      final List<Map<String, dynamic>> uiList = movements.map((e) => {
        'id': e.id,
        'name': e.name,
        'money': e.amount,
        'type': e.type.name,
        'isIncome': e.isIncome,
        'isSpent': e.isSpent,
        'currentDate': e.date,
        'currentHour': e.hour,
        'month': e.month,
        'year': e.year,
        'createdAt': e.createdAt.toIso8601String(),
      }).toList();
      
      emit(state.copyWith(historyList: uiList, status: HistoryStatus.success));
    } catch (e) {
      emit(state.copyWith(status: HistoryStatus.failure, isSyncing: false));
    }
  }

  // --- MÉTODOS DE ACTUALIZACIÓN LOCAL (Soportando el split de tablas) ---

  Future<void> addMovementLocally(dynamic item) async {
    if (item is LocalSaving) {
      await _localDb.saveSavingItems([item]);
    } else if (item is LocalHistory) {
      await _localDb.saveHistoryItems([item]);
      await _updateBalance(item.money, item.type == 'income');
    }
    await loadHistoryByDate(item.month, item.year);
  }

  Future<void> updateMovementLocally(dynamic item, double oldAmount) async {
    final isar = _localDb.isar;
    
    if (item is LocalSaving) {
      final existing = await isar.localSavings.filter().appwriteIdEqualTo(item.appwriteId).findFirst();
      if (existing != null) item.id = existing.id;
      await _localDb.saveSavingItems([item]);
    } else if (item is LocalHistory) {
      final existing = await isar.localHistorys.filter().appwriteIdEqualTo(item.appwriteId).findFirst();
      if (existing != null) item.id = existing.id;
      await _localDb.saveHistoryItems([item]);
      
      final double diff = item.type == 'income' ? (item.money - oldAmount) : (oldAmount - item.money);
      if (diff != 0) await _updateBalance(diff.abs(), diff > 0);
    }
    
    await loadHistoryByDate(item.month, item.year);
  }

  Future<void> deleteMovementLocally(String appwriteId, String month, int year, double amount, String type) async {
    await _localDb.deleteItemByAppwriteId(appwriteId);
    if (type != 'saving') {
      await _updateBalance(amount, type == 'expense');
    }
    await loadHistoryByDate(month, year);
  }

  Future<void> _updateBalance(double amount, bool isAddition) async {
    double current = await _localDb.getTotalBalance(Preferences.uId);
    final double newBalance = isAddition ? current + amount : current - amount;
    await _localDb.saveTotalBalance(Preferences.uId, newBalance);
    await _repository.updateTotalBalance(newBalance);
    totalMoneyCubit.totalMoney(newBalance);
  }

  List<LocalHistory> _convertToLocalHistory(dynamic historyDocs) {
    return (historyDocs as List).map((doc) => LocalHistory()
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
    ).toList();
  }

  List<LocalSaving> _convertToLocalSaving(dynamic savingsDocs) {
    return (savingsDocs as List).map((doc) {
      final DateTime date = DateTime.parse(doc.$createdAt);
      return LocalSaving()
        ..appwriteId = doc.$id
        ..userId = doc.data['userId'] ?? ''
        ..money = (doc.data['money'] as num).toDouble()
        ..month = doc.data['month'] ?? ''
        ..year = doc.data['year'] ?? 0
        ..description = doc.data['description'] ?? 'Ahorro'
        ..isSpent = doc.data['isSpent'] ?? false
        ..createdAt = date;
    }).toList();
  }

  void toggleIncomes(bool value) => emit(state.copyWith(showIncomes: value));
  void toggleExpenses(bool value) => emit(state.copyWith(showExpenses: value));
  void toggleSavings(bool value) => emit(state.copyWith(showSavings: value));
  void toggleFilterPanel() => emit(state.copyWith(isFilterOpen: !state.isFilterOpen));
  void listOrder(String value) => emit(state.copyWith(listOrder: value));
  void isChart(bool value) => emit(state.copyWith(isChart: value));
  void resetCubit() => emit(state.copyWith(newName: const IncomeNameInput.pure(), newMoney: const IncomeMoneyInput.pure(), status: HistoryStatus.initial));
  void newNameChanged(String value) { final newName = IncomeNameInput.dirty(value: value); emit(state.copyWith(newName: newName, isValid: Formz.validate([newName, state.newMoney]))); }
  void newMoneyChanged(String value) { final newMoney = IncomeMoneyInput.dirty(value: value); emit(state.copyWith(newMoney: newMoney, isValid: Formz.validate([newMoney, state.newName]))); }
}
