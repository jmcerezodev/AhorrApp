import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/local_history.dart';
import 'models/local_settings.dart';
import 'models/pending_sync.dart';

class LocalDbService {
  static final LocalDbService _instance = LocalDbService._internal();
  late Isar _isar;

  factory LocalDbService() => _instance;

  LocalDbService._internal();

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    if (Isar.instanceNames.isEmpty) {
      _isar = await Isar.open(
        [LocalHistorySchema, LocalSettingsSchema, PendingSyncSchema],
        directory: dir.path,
      );
    } else {
      _isar = Isar.getInstance()!;
    }
  }

  // --- CONSULTAS ---

  Future<int> getTotalCount() async {
    return await _isar.localHistorys.count();
  }

  Future<int> getMinYear() async {
    final firstItem = await _isar.localHistorys
        .filter()
        .yearGreaterThan(0)
        .sortByYear()
        .findFirst();
    return firstItem?.year ?? DateTime.now().year;
  }

  Future<List<LocalHistory>> getYearlyActivity(int year) async {
    return await _isar.localHistorys
        .filter()
        .yearEqualTo(year)
        .findAll();
  }

  // --- HISTORIAL ---

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

  // --- AJUSTES Y BALANCE ---

  Future<void> saveSavingGoal(String userId, double goal) async {
    await _isar.writeTxn(() async {
      final settings = await _isar.localSettings.filter().userIdEqualTo(userId).findFirst() ?? LocalSettings()..userId = userId;
      settings.savingGoal = goal;
      await _isar.localSettings.put(settings);
    });
  }

  Future<double> getSavingGoal(String userId) async {
    final settings = await _isar.localSettings.filter().userIdEqualTo(userId).findFirst();
    return settings?.savingGoal ?? 0.0;
  }

  Future<void> saveTotalBalance(String userId, double balance) async {
    await _isar.writeTxn(() async {
      final settings = await _isar.localSettings.filter().userIdEqualTo(userId).findFirst() ?? LocalSettings()..userId = userId;
      settings.totalBalance = balance;
      await _isar.localSettings.put(settings);
    });
  }

  Future<double> getTotalBalance(String userId) async {
    final settings = await _isar.localSettings.filter().userIdEqualTo(userId).findFirst();
    return settings?.totalBalance ?? 0.0;
  }

  // ACTUALIZADO: Solo sumamos los ahorros que NO han sido gastados/vaciados
  Future<double> calculateTotalSavings(String userId) async {
    final savings = await _isar.localHistorys
        .filter()
        .typeEqualTo('saving')
        .isSpentEqualTo(false)
        .findAll();
    
    double total = 0;
    for (var s in savings) {
      total += s.money;
    }
    return total;
  }

  // NUEVO: Marcar todos los ahorros actuales como "gastados"
  Future<List<String>> markSavingsAsSpent() async {
    final savings = await _isar.localHistorys
        .filter()
        .typeEqualTo('saving')
        .isSpentEqualTo(false)
        .findAll();
    
    final List<String> idsToUpdate = [];
    
    await _isar.writeTxn(() async {
      for (var s in savings) {
        s.isSpent = true;
        idsToUpdate.add(s.appwriteId);
        await _isar.localHistorys.put(s);
      }
    });
    
    return idsToUpdate;
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
      await _isar.localSettings.clear();
      await _isar.pendingSyncs.clear();
    });
  }

  Future<void> deleteItemByAppwriteId(String appwriteId) async {
    await _isar.writeTxn(() async {
      await _isar.localHistorys.filter().appwriteIdEqualTo(appwriteId).deleteAll();
    });
  }
}
