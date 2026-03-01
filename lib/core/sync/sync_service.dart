import 'dart:async';
import 'dart:convert';
import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/data/local/models/pending_sync.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SyncService {
  // Ahora usamos getIt para obtener las dependencias
  final LocalDbService _localDb = getIt<LocalDbService>();
  final AppwriteRepository _appwriteRepo = getIt<AppwriteRepository>();
  
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isSyncing = false;

  void init() {
    _subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.any((result) => result != ConnectivityResult.none)) {
        processQueue();
      }
    });
    processQueue();
  }

  void dispose() {
    _subscription?.cancel();
  }

  Future<void> processQueue() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      // Si la DB no está lista, salimos silenciosamente (esto protege los tests)
      final pendingList = await _localDb.getPendingSyncs();
      if (pendingList.isEmpty) {
        _isSyncing = false;
        return;
      }

      for (var pending in pendingList) {
        bool success = false;
        final Map<String, dynamic> data = jsonDecode(pending.dataJson);

        try {
          if (pending.collection == 'history') {
            success = await _syncHistory(pending, data);
          } else if (pending.collection == 'savings') {
            success = await _syncSavings(pending, data);
          } else if (pending.collection == 'settings') {
            success = await _syncSettings(pending, data);
          }

          if (success) {
            await _localDb.deletePendingSync(pending.id);
          }
        } catch (e) {
          break;
        }
      }
    } catch (e) {
      // Error manejado para evitar crashes
    } finally {
      _isSyncing = false;
    }
  }

  Future<bool> _syncHistory(PendingSync pending, Map<String, dynamic> data) async {
    if (pending.action == 'create') {
      await _appwriteRepo.addHistory(
        userId: data['userId'],
        name: data['name'],
        money: data['money'],
        isIncome: data['isIncome'],
        currentDate: data['currentDate'] ?? '',
        currentHour: data['currentHour'] ?? '',
        month: data['month'],
        year: data['year'],
      );
      return true;
    } else if (pending.action == 'update') {
      await _appwriteRepo.updateHistory(documentId: pending.appwriteId!, data: data);
      return true;
    } else if (pending.action == 'delete') {
      await _appwriteRepo.deleteHistory(pending.appwriteId!);
      return true;
    }
    return false;
  }

  Future<bool> _syncSavings(PendingSync pending, Map<String, dynamic> data) async {
    if (pending.action == 'create') {
      await _appwriteRepo.addSaving(
        userId: data['userId'],
        money: data['money'],
        month: data['month'],
        year: data['year'],
        description: data['description'],
      );
      return true;
    } else if (pending.action == 'update') {
      await _appwriteRepo.updateSaving(documentId: pending.appwriteId!, money: data['money']);
      return true;
    } else if (pending.action == 'delete') {
      await _appwriteRepo.deleteSaving(pending.appwriteId!);
      return true;
    }
    return false;
  }

  Future<bool> _syncSettings(PendingSync pending, Map<String, dynamic> data) async {
    if (pending.action == 'update_goal') {
      await _appwriteRepo.updatePrefs({'savingGoal': data['savingGoal']});
      return true;
    } else if (pending.action == 'update_balance') {
      await _appwriteRepo.updateTotalBalance(data['totalBalance']);
      return true;
    }
    return false;
  }
}
