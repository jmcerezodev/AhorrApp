import 'dart:async';
import 'dart:convert';
import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/network/connectivity_service.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/data/local/models/pending_sync.dart';
import 'package:appwrite/appwrite.dart';

class SyncService {
  final LocalDbService _localDb = getIt<LocalDbService>();
  final AppwriteRepository _appwriteRepo = getIt<AppwriteRepository>();
  final ConnectivityService _connectivityService = getIt<ConnectivityService>();
  
  StreamSubscription<NetworkStatus>? _subscription;
  bool _isSyncing = false;

  void init() {
    _subscription = _connectivityService.status.listen((status) {
      if (status == NetworkStatus.online) {
        processQueue();
      }
    });
    processQueue();
  }

  void dispose() {
    _subscription?.cancel();
  }

  Future<void> processQueue() async {
    if (_isSyncing || !Preferences.isLoggedIn || !(await _connectivityService.isConnected)) return;
    
    _isSyncing = true;

    try {
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
          if (e is AppwriteException && (e.code == 401 || e.code == 403)) {
            final reauthSuccess = await _attemptSilentLogin();
            if (reauthSuccess) {
              _isSyncing = false;
              // Await the recursive call to ensure the whole process completes
              await processQueue();
              return;
            }
          }

          if (e is AppwriteException && e.code == 409) {
             await _localDb.deletePendingSync(pending.id);
          }
          continue; 
        }
      }
    } catch (e) {
      // General error handling
    } finally {
      _isSyncing = false;
    }
  }

  Future<bool> _attemptSilentLogin() async {
    if (!Preferences.isLoggedIn) return false;

    final String email = Preferences.email;
    final String password = Preferences.password;

    if (email.isEmpty || password.isEmpty) return false;

    try {
      final authService = getIt<AuthAppwrite>();
      final result = await authService.signInEmailAndPassword(email, password);
      return result is String;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _syncHistory(PendingSync pending, Map<String, dynamic> data) async {
    if (pending.action == 'create') {
      await _appwriteRepo.addHistory(
        documentId: pending.appwriteId!,
        userId: data['userId'] ?? '',
        name: data['name'] ?? '',
        money: (data['money'] as num?)?.toDouble() ?? 0.0,
        isIncome: data['isIncome'] ?? false,
        currentDate: data['currentDate'] ?? data['date'] ?? '',
        currentHour: data['currentHour'] ?? data['hour'] ?? '',
        month: data['month'] ?? '',
        year: data['year'] ?? 0,
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
        documentId: pending.appwriteId!,
        userId: data['userId'] ?? '',
        money: (data['money'] as num?)?.toDouble() ?? 0.0,
        month: data['month'] ?? '',
        year: data['year'] ?? 0,
        description: data['description'] ?? '',
        isSpent: data['isSpent'] ?? false,
      );
      return true;
    } else if (pending.action == 'update') {
      final Map<String, dynamic> cleanData = {};
      if (data.containsKey('description')) cleanData['description'] = data['description'];
      if (data.containsKey('name')) cleanData['description'] = data['name'];
      if (data.containsKey('money')) cleanData['money'] = data['money'];
      if (data.containsKey('isSpent')) cleanData['isSpent'] = data['isSpent'];

      await _appwriteRepo.updateSaving(documentId: pending.appwriteId!, data: cleanData);
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
      await _appwriteRepo.updateTotalBalance((data['totalBalance'] as num?)?.toDouble() ?? 0.0);
      return true;
    }
    return false;
  }
}
