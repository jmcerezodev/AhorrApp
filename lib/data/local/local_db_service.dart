import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/local_history.dart';
import 'models/local_saving.dart';
import 'models/financial_summary.dart';
import 'models/pending_sync.dart';
import 'models/local_recurrent_expense.dart';
import 'models/local_shopping_list_item.dart';
import 'models/local_shopping_template.dart';
import 'models/local_ticket_item.dart';
import 'models/local_debt_loan.dart';

class LocalDbService {
  static final LocalDbService _instance = LocalDbService._internal();
  late Isar _isar;

  Isar get isar => _isar;

  factory LocalDbService() => _instance;

  LocalDbService._internal();

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    if (Isar.instanceNames.isEmpty) {
      _isar = await Isar.open(
        [
          LocalHistorySchema,
          LocalSavingSchema,
          FinancialSummarySchema,
          PendingSyncSchema,
          LocalRecurrentExpenseSchema,
          LocalShoppingItemSchema,
          LocalShoppingTemplateSchema,
          LocalTicketItemSchema,
          LocalDebtLoanSchema,
        ],
        directory: dir.path,
        inspector: kDebugMode,
      );
    } else {
      _isar = Isar.getInstance()!;
    }
  }

  // --- CONSULTAS ---

  Future<int> getTotalCount() async {
    final int historyCount = await _isar.localHistorys.count();
    final int savingsCount = await _isar.localSavings.count();
    final int recurrentCount = await _isar.localRecurrentExpenses.count();
    final int debtCount = await _isar.localDebtLoans.count();
    return historyCount + savingsCount + recurrentCount + debtCount;
  }

  Future<int> getMinYear() async {
    final firstHistory = await _isar.localHistorys
        .filter()
        .yearGreaterThan(0)
        .sortByYear()
        .findFirst();
    final firstSaving = await _isar.localSavings
        .filter()
        .yearGreaterThan(0)
        .sortByYear()
        .findFirst();

    int historyYear = firstHistory?.year ?? DateTime.now().year;
    int savingYear = firstSaving?.year ?? DateTime.now().year;

    return historyYear < savingYear ? historyYear : savingYear;
  }

  Future<List<LocalHistory>> getYearlyActivity(int year) async {
    return await _isar.localHistorys
        .filter()
        .yearEqualTo(year)
        .findAll();
  }

  Future<List<LocalHistory>> getAllHistory() async {
    return await _isar.localHistorys.where().sortByCreatedAtDesc().findAll();
  }

  // --- HISTORIAL (INGRESOS / GASTOS) ---

  Future<void> saveHistoryItems(List<LocalHistory> items) async {
    await _isar.writeTxn(() async {
      await _isar.localHistorys.putAll(items);
    });
  }

  Future<List<LocalHistory>> getHistoryByMonth(String month, int year) async {
    return await _isar.localHistorys
        .filter()
        .monthEqualTo(month, caseSensitive: false)
        .yearEqualTo(year)
        .sortByCreatedAtDesc()
        .findAll();
  }

  // --- AHORROS ---

  Future<void> saveSavingItems(List<LocalSaving> items) async {
    await _isar.writeTxn(() async {
      await _isar.localSavings.putAll(items);
    });
  }

  Future<List<LocalSaving>> getSavingsByMonth(String month, int year) async {
    return await _isar.localSavings
        .filter()
        .monthEqualTo(month, caseSensitive: false)
        .yearEqualTo(year)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<double> calculateTotalSavings(String userId) async {
    final savings = await _isar.localSavings
        .filter()
        .userIdEqualTo(userId)
        .isSpentEqualTo(false)
        .findAll();
    
    double total = 0.0;
    for (var s in savings) {
      total += s.money;
    }
    return total;
  }

  Future<List<String>> markSavingsAsSpent() async {
    final savings = await _isar.localSavings
        .filter()
        .isSpentEqualTo(false)
        .findAll();
    
    final List<String> idsToUpdate = [];
    
    await _isar.writeTxn(() async {
      for (var s in savings) {
        s.isSpent = true;
        idsToUpdate.add(s.appwriteId);
        await _isar.localSavings.put(s);
      }
    });
    
    return idsToUpdate;
  }

  // --- GASTOS RECURRENTES (FIJOS) ---

  Future<void> saveRecurrentExpenses(List<LocalRecurrentExpense> items) async {
    await _isar.writeTxn(() async {
      await _isar.localRecurrentExpenses.putAll(items);
    });
  }

  Future<List<LocalRecurrentExpense>> getRecurrentExpenses(String userId) async {
    return await _isar.localRecurrentExpenses
        .filter()
        .userIdEqualTo(userId)
        .findAll();
  }

  Future<void> deleteRecurrentExpenseByAppwriteId(String appwriteId) async {
    await _isar.writeTxn(() async {
      await _isar.localRecurrentExpenses.filter().appwriteIdEqualTo(appwriteId).deleteAll();
    });
  }

  // --- LISTA DE LA COMPRA ---

  Future<void> saveShoppingListItems(List<LocalShoppingItem> items) async {
    await _isar.writeTxn(() async {
      await _isar.localShoppingItems.putAll(items);
    });
  }

  Future<List<LocalShoppingItem>> getShoppingList(String userId) async {
    return await _isar.localShoppingItems
        .filter()
        .userIdEqualTo(userId)
        .findAll();
  }

  Future<void> deleteShoppingItemByAppwriteId(String appwriteId) async {
    await _isar.writeTxn(() async {
      await _isar.localShoppingItems.filter().appwriteIdEqualTo(appwriteId).deleteAll();
    });
  }

  // --- PLANTILLAS DE COMPRA ---

  Future<void> saveShoppingTemplates(List<LocalShoppingTemplate> items) async {
    await _isar.writeTxn(() async {
      await _isar.localShoppingTemplates.putAll(items);
    });
  }

  Future<List<LocalShoppingTemplate>> getShoppingTemplates(String userId) async {
    return await _isar.localShoppingTemplates
        .filter()
        .userIdEqualTo(userId)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Future<void> deleteShoppingTemplateByAppwriteId(String appwriteId) async {
    await _isar.writeTxn(() async {
      await _isar.localShoppingTemplates.filter().appwriteIdEqualTo(appwriteId).deleteAll();
    });
  }

  // --- TICKETS ---

  Future<void> saveTicketItems(List<LocalTicketItem> items) async {
    await _isar.writeTxn(() async {
      await _isar.localTicketItems.putAll(items);
    });
  }

  // --- DEUDAS Y PRÉSTAMOS ---

  Future<void> saveDebtLoans(List<LocalDebtLoan> items) async {
    await _isar.writeTxn(() async {
      await _isar.localDebtLoans.putAll(items);
    });
  }

  Future<List<LocalDebtLoan>> getDebtLoans(String userId) async {
    return await _isar.localDebtLoans
        .filter()
        .userIdEqualTo(userId)
        .findAll();
  }

  Future<void> deleteDebtLoanByAppwriteId(String appwriteId) async {
    await _isar.writeTxn(() async {
      await _isar.localDebtLoans.filter().appwriteIdEqualTo(appwriteId).deleteAll();
    });
  }

  // --- RESUMEN FINANCIERO ---

  Future<void> saveSavingGoal(String userId, double goal) async {
    await _isar.writeTxn(() async {
      final summary = await _isar.financialSummarys.filter().userIdEqualTo(userId).findFirst() ?? FinancialSummary()..userId = userId;
      summary.savingGoal = goal;
      await _isar.financialSummarys.put(summary);
    });
  }

  Future<double> getSavingGoal(String userId) async {
    final summary = await _isar.financialSummarys.filter().userIdEqualTo(userId).findFirst();
    return summary?.savingGoal ?? 0.0;
  }

  Future<void> saveTotalBalance(String userId, double balance) async {
    await _isar.writeTxn(() async {
      final summary = await _isar.financialSummarys.filter().userIdEqualTo(userId).findFirst() ?? FinancialSummary()..userId = userId;
      summary.totalBalance = balance;
      await _isar.financialSummarys.put(summary);
    });
  }

  Future<double> getTotalBalance(String userId) async {
    final summary = await _isar.financialSummarys.filter().userIdEqualTo(userId).findFirst();
    return summary?.totalBalance ?? 0.0;
  }

  // --- COLA DE SINCRONIZACIÓN ---

  Future<void> addPendingSync(String action, String collection, Map<String, dynamic> data, {String? appwriteId}) async {
    await _isar.writeTxn(() async {
      final pending = PendingSync()
        ..action = action
        ..collection = collection
        ..dataJson = jsonEncode(data)
        ..appwriteId = appwriteId
        ..createdAt = DateTime.now();
      await _isar.pendingSyncs.put(pending);
    });
  }

  Future<List<PendingSync>> getPendingSyncs() async {
    return await _isar.pendingSyncs.where().sortByCreatedAt().findAll();
  }

  Future<void> deletePendingSync(int id) async {
    await _isar.writeTxn(() async {
      await _isar.pendingSyncs.delete(id);
    });
  }

  // --- GENERAL ---

  Future<void> clearAll() async {
    await _isar.writeTxn(() async {
      await _isar.localHistorys.clear();
      await _isar.localSavings.clear();
      await _isar.financialSummarys.clear();
      await _isar.pendingSyncs.clear();
      await _isar.localRecurrentExpenses.clear();
      await _isar.localShoppingItems.clear();
      await _isar.localShoppingTemplates.clear();
      await _isar.localTicketItems.clear();
      await _isar.localDebtLoans.clear();
    });
  }

  Future<void> deleteItemByAppwriteId(String appwriteId) async {
    await _isar.writeTxn(() async {
      await _isar.localHistorys.filter().appwriteIdEqualTo(appwriteId).deleteAll();
      await _isar.localSavings.filter().appwriteIdEqualTo(appwriteId).deleteAll();
      await _isar.localRecurrentExpenses.filter().appwriteIdEqualTo(appwriteId).deleteAll();
      await _isar.localShoppingItems.filter().appwriteIdEqualTo(appwriteId).deleteAll();
      await _isar.localShoppingTemplates.filter().appwriteIdEqualTo(appwriteId).deleteAll();
      await _isar.localDebtLoans.filter().appwriteIdEqualTo(appwriteId).deleteAll();
    });
  }
}
