import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/inputs/inputs.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/data/local/models/local_history.dart';
import 'package:ahorrapp/data/local/models/local_recurrent_expense.dart';
import 'package:ahorrapp/data/local/models/local_saving.dart';
import 'package:ahorrapp/data/local/models/local_shopping_list_item.dart';
import 'package:ahorrapp/data/local/models/local_shopping_template.dart';
import 'package:ahorrapp/data/local/models/local_ticket_item.dart';
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
    if (Preferences.uId.isEmpty) return;
    final date = Date();
    await loadHistoryByDate(date.monthNames(), int.parse(date.year()));
  }

  void resetCubit() {
    emit(const HistoryCubitState());
  }

  Future<void> prepareForNewLogin() async {
    await _localDb.clearAll();
    emit(const HistoryCubitState());
  }

  Future<void> forceBalanceResync(TotalMoneyCubit totalMoneyCubit, {SavingsCubit? savingsCubit, TicketsCubit? ticketsCubit}) async {
    if (state.isSyncing || Preferences.uId.isEmpty) return;

    emit(state.copyWith(status: HistoryStatus.loading, isSyncing: true, syncProgress: 0.0));
    try {
      await _localDb.clearAll();
      final String uid = Preferences.uId;
      final fullData = await _repository.syncFullData(uid, (progress) => emit(state.copyWith(syncProgress: progress)));
      
      final List<LocalHistory> historyItems = _convertToLocalHistory(fullData['history']);
      await _localDb.saveHistoryItems(historyItems);
      
      final List<LocalSaving> savingItems = _convertToLocalSaving(fullData['savings']);
      await _localDb.saveSavingItems(savingItems);

      final List<LocalRecurrentExpense> recurrentItems = _convertToLocalRecurrent(fullData['recurrent']);
      await _localDb.saveRecurrentExpenses(recurrentItems);

      final List<LocalShoppingItem> shoppingItems = _convertToLocalShopping(fullData['shopping']);
      await _localDb.saveShoppingListItems(shoppingItems);

      final List<LocalShoppingTemplate> templateItems = _convertToLocalTemplates(fullData['templates']);
      await _localDb.saveShoppingTemplates(templateItems);

      // NUEVO: Guardar Tickets usando el método de LocalDbService
      final List<LocalTicketItem> ticketItems = _convertToLocalTickets(fullData['tickets'] ?? []);
      await _localDb.saveTicketItems(ticketItems);

      await _localDb.saveSavingGoal(uid, fullData['savingGoal']);
      final double correctBalance = (fullData['balance'] as num).toDouble();
      await _localDb.saveTotalBalance(uid, correctBalance);
      totalMoneyCubit.totalMoney(correctBalance);
      
      if (savingsCubit != null) {
        await savingsCubit.loadSavings();
      }

      if (ticketsCubit != null) {
        await ticketsCubit.loadItems();
      }
      
      emit(state.copyWith(isSyncing: false, syncProgress: 1.0, status: HistoryStatus.success));
      final date = Date();
      await _loadRawHistory(date.monthNames(), int.parse(date.year()));
    } catch (e) {
      emit(state.copyWith(isSyncing: false, status: HistoryStatus.failure));
    }
  }

  Future<void> _loadRawHistory(String month, int year) async {
    final movements = await _getMovementsUseCase(Preferences.uId, month, year);
    final uiList = movements.map((e) => {
      'id': e.id, 'name': e.name, 'money': e.amount, 'type': e.type.name, 'isIncome': e.isIncome,
      'isSpent': e.isSpent, 'currentDate': e.date, 'currentHour': e.hour, 'month': e.month, 'year': e.year,
      'createdAt': e.createdAt.toIso8601String(),
      'isRecurrent': e.isRecurrent,
      'category': e.category,
      'ticketId': e.ticketId,
      'imagePath': e.imagePath,
      'remoteImageId': e.remoteImageId, // AÑADIDO
      'isTransferred': e.isTransferred,
    }).toList();
    emit(state.copyWith(historyList: uiList, status: HistoryStatus.success));
  }

  Future<void> loadHistoryByDate(String month, int year, {SavingsCubit? savingsCubit}) async {
    if (year == 0 || Preferences.uId.isEmpty) return;
    if (state.isSyncing) return;

    final localTotalCount = await _localDb.getTotalCount();
    if (localTotalCount == 0 && state.syncProgress == 0.0) {
      await forceBalanceResync(totalMoneyCubit, savingsCubit: savingsCubit);
      return;
    }

    emit(state.copyWith(status: HistoryStatus.loading));
    try {
      double globalBalance = await _localDb.getTotalBalance(Preferences.uId);
      totalMoneyCubit.totalMoney(globalBalance);
      final movements = await _getMovementsUseCase(Preferences.uId, month, year);
      final uiList = movements.map((e) => {
        'id': e.id, 'name': e.name, 'money': e.amount, 'type': e.type.name, 'isIncome': e.isIncome,
        'isSpent': e.isSpent, 'currentDate': e.date, 'currentHour': e.hour, 'month': e.month, 'year': e.year,
        'createdAt': e.createdAt.toIso8601String(),
        'isRecurrent': e.isRecurrent,
        'category': e.category,
        'ticketId': e.ticketId,
        'imagePath': e.imagePath,
        'remoteImageId': e.remoteImageId, // AÑADIDO
        'isTransferred': e.isTransferred,
      }).toList();
      emit(state.copyWith(historyList: uiList, status: HistoryStatus.success));
    } catch (e) {
      emit(state.copyWith(status: HistoryStatus.failure, isSyncing: false));
    }
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
      
      double diff;
      if (item.type == 'income') {
        diff = item.money - oldAmount;
      } else {
        diff = oldAmount - item.money;
      }

      if (diff != 0) {
        await _updateBalance(diff.abs(), diff > 0);
      }
    }
    await loadHistoryByDate(item.month, item.year);
  }

  Future<void> deleteMovementLocally(String appwriteId, String month, int year, double amount, String type) async {
    await _localDb.deleteItemByAppwriteId(appwriteId);
    if (type != 'saving') {
      final bool shouldAdd = (type == 'expense');
      await _updateBalance(amount, shouldAdd);
    }
    await loadHistoryByDate(month, year);
  }

  Future<void> _updateBalance(double amount, bool isAddition) async {
    double current = await _localDb.getTotalBalance(Preferences.uId);
    
    double newBalance;
    if (isAddition) {
      newBalance = ((current + amount) * 100).roundToDouble() / 100;
    } else {
      newBalance = ((current - amount) * 100).roundToDouble() / 100;
    }

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
      ..isRecurrent = doc.data['isRecurrent'] ?? false
      ..category = doc.data['category'] ?? (doc.data['isIncome'] == true ? 'otro' : 'general')
      ..ticketId = doc.data['ticketId']
      ..imagePath = doc.data['imagePath']
      ..remoteImageId = doc.data['remoteImageId'] // AÑADIDO
      ..isTransferred = doc.data['isTransferred'] ?? false
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

  List<LocalRecurrentExpense> _convertToLocalRecurrent(dynamic recurrentDocs) {
    return (recurrentDocs as List).map((doc) {
      return LocalRecurrentExpense()
        ..appwriteId = doc.$id
        ..userId = doc.data['userId'] ?? ''
        ..name = doc.data['name'] ?? 'Gasto Fijo'
        ..money = (doc.data['money'] as num).toDouble()
        ..day = doc.data['day']
        ..category = doc.data['category'] ?? 'general'
        ..isActive = doc.data['isActive'] ?? true
        ..lastApplied = doc.data['lastApplied']
        ..frequency = _mapFrequency(doc.data['frequency'] ?? 'monthly')
        ..startDate = DateTime.parse(doc.data['startDate'] ?? doc.$createdAt)
        ..position = doc.data['position'] ?? 0 
        ..includeInSummary = doc.data['includeInSummary'] ?? true
        ..createdAt = DateTime.parse(doc.$createdAt);
    }).toList();
  }

  List<LocalShoppingItem> _convertToLocalShopping(dynamic shoppingDocs) {
    return (shoppingDocs as List).map((doc) {
      return LocalShoppingItem()
        ..appwriteId = doc.$id
        ..userId = doc.data['userId'] ?? ''
        ..name = doc.data['name'] ?? 'Producto'
        ..amount = (doc.data['amount'] as num).toDouble()
        ..category = doc.data['category'] ?? 'general'
        ..isBought = doc.data['isBought'] ?? false
        ..position = doc.data['position'] ?? 0
        ..quantity = doc.data['quantity'] ?? 1
        ..createdAt = DateTime.parse(doc.$createdAt);
    }).toList();
  }

  List<LocalShoppingTemplate> _convertToLocalTemplates(dynamic templateDocs) {
    return (templateDocs as List).map((doc) {
      return LocalShoppingTemplate()
        ..appwriteId = doc.$id
        ..userId = doc.data['userId'] ?? ''
        ..name = doc.data['name'] ?? 'Favorito'
        ..itemsJson = doc.data['itemsJson'] ?? '[]'
        ..createdAt = DateTime.parse(doc.$createdAt);
    }).toList();
  }

  List<LocalTicketItem> _convertToLocalTickets(dynamic ticketDocs) {
    return (ticketDocs as List).map((doc) {
      return LocalTicketItem()
        ..ticketItemId = doc.data['ticketItemId'] ?? doc.$id
        ..userId = doc.data['userId'] ?? ''
        ..name = doc.data['name'] ?? ''
        ..amount = (doc.data['amount'] as num).toDouble()
        ..date = DateTime.parse(doc.data['date'] ?? doc.$createdAt)
        ..category = doc.data['category'] ?? 'general'
        ..position = doc.data['position'] ?? 0
        ..isTransferred = doc.data['isTransferred'] ?? false
        ..remoteImageId = doc.data['remoteImageId'];
    }).toList();
  }

  LocalRecurrentFrequency _mapFrequency(String freq) {
    switch (freq) {
      case 'annually':
        return LocalRecurrentFrequency.annually;
      case 'semiAnnually':
        return LocalRecurrentFrequency.semiAnnually;
      case 'quarterly':
        return LocalRecurrentFrequency.quarterly;
      default:
        return LocalRecurrentFrequency.monthly;
    }
  }

  void toggleIncomes(bool value) => emit(state.copyWith(showIncomes: value));
  void toggleExpenses(bool value) => emit(state.copyWith(showExpenses: value));
  void toggleSavings(bool value) => emit(state.copyWith(showSavings: value));
  void toggleFilterPanel() => emit(state.copyWith(isFilterOpen: !state.isFilterOpen));
  void listOrder(String value) => emit(state.copyWith(listOrder: value));
  void isChart(bool value) => emit(state.copyWith(isChart: value));
  void newNameChanged(String value) { final newName = IncomeNameInput.dirty(value: value); emit(state.copyWith(newName: newName, isValid: Formz.validate([newName, state.newMoney]))); }
  void newMoneyChanged(String value) { final newMoney = IncomeMoneyInput.dirty(value: value); emit(state.copyWith(newMoney: newMoney, isValid: Formz.validate([newMoney, state.newName]))); }
}
