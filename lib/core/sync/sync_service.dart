import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/network/connectivity_service.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/data/local/models/pending_sync.dart';
import 'package:ahorrapp/data/local/models/local_ticket_item.dart';
import 'package:ahorrapp/domain/repositories/debt_loan_repository.dart';
import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';

enum SyncStatus { idle, syncing, success, error }
enum _SyncResult { success, retry, fatal }

class SyncService {
  final LocalDbService _localDb = getIt<LocalDbService>();
  final AppwriteRepository _appwriteRepo = getIt<AppwriteRepository>();
  final ConnectivityService _connectivityService = getIt<ConnectivityService>();
  
  StreamSubscription<NetworkStatus>? _subscription;
  bool _isSyncing = false;

  // --- LÓGICA DE BACKOFF ---
  int _errorCount = 0;
  DateTime? _nextRetryTime;
  final ValueNotifier<SyncStatus> syncStatusNotifier = ValueNotifier(SyncStatus.idle);
  
  static const int _maxItemRetries = 5;
  
  // Guard para evitar que sincronizaciones automáticas pisen el estado visual de una manual
  bool _isManualInResultState = false;

  // Tiempo de la última sincronización manual exitosa para evitar peticiones redundantes
  DateTime? _lastManualSyncTime;

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
    syncStatusNotifier.dispose();
  }

  /// Fuerza una sincronización inmediata ignorando el cooldown del backoff.
  Future<void> forceSync() async {
    _errorCount = 0;
    _nextRetryTime = null;
    _isManualInResultState = false; 
    await processQueue(isManual: true);
  }

  Future<void> processQueue({bool isManual = false}) async {
    if (!isManual && _isManualInResultState) return;

    if (!isManual && _lastManualSyncTime != null && 
        DateTime.now().difference(_lastManualSyncTime!).inSeconds < 30) {
      debugPrint('⏳ Sincronización automática bloqueada por cooldown manual.');
      return;
    }
    
    if (_isSyncing || !Preferences.isLoggedIn) return;
    
    if (!isManual && _nextRetryTime != null && DateTime.now().isBefore(_nextRetryTime!)) {
      debugPrint('⏳ Sincronización en cooldown hasta: $_nextRetryTime');
      return;
    }

    if (!(await _connectivityService.isConnected)) {
      if (isManual) {
        _isManualInResultState = true;
        syncStatusNotifier.value = SyncStatus.error;
        _resetManualGuardAfterDelay();
      }
      return;
    }
    
    _isSyncing = true;
    
    if (isManual || !_isManualInResultState) {
      syncStatusNotifier.value = SyncStatus.syncing;
    }

    try {
      final pendingList = await _localDb.getPendingSyncs();
      if (pendingList.isEmpty) {
        if (isManual) {
          _isManualInResultState = true;
          _lastManualSyncTime = DateTime.now();
          syncStatusNotifier.value = SyncStatus.success;
          _resetManualGuardAfterDelay();
        } else if (!_isManualInResultState) {
          syncStatusNotifier.value = SyncStatus.idle;
        }
        _isSyncing = false;
        return;
      }

      bool hasNetworkError = false;
      bool hasItemError = false;

      for (var pending in pendingList) {
        _SyncResult result = _SyncResult.retry;
        final Map<String, dynamic> data = jsonDecode(pending.dataJson);

        try {
          result = await _executeSyncItem(pending, data);

          if (result == _SyncResult.success) {
            await _localDb.deletePendingSync(pending.id);
            // No reseteamos el backoff global aquí para permitir que otros items fallen
            // pero si todo va bien, al final se resetea.
          } else if (result == _SyncResult.fatal) {
            debugPrint('❌ Fallo fatal en ítem ${pending.collection} (ID: ${pending.id}). Eliminando de la cola.');
            await _localDb.deletePendingSync(pending.id);
          } else {
            // Reintento por error puntual del ítem o fallo lógico
            pending.retryCount++;
            if (pending.retryCount >= _maxItemRetries) {
              debugPrint('⚠️ Máximo de reintentos alcanzado para ${pending.collection} (ID: ${pending.id}). Descartando.');
              await _localDb.deletePendingSync(pending.id);
            } else {
              await _localDb.isar.writeTxn(() async {
                await _localDb.isar.pendingSyncs.put(pending);
              });
              hasItemError = true;
              // Continuamos con el siguiente ítem para evitar bloqueo global
              continue; 
            }
          }
        } catch (e) {
          if (e is AppwriteException) {
            final int code = e.code ?? 0;
            // Errores de autenticación: Intentar login silencioso y reanudar
            if (code == 401 || code == 403) {
              final reauthSuccess = await _attemptSilentLogin();
              if (reauthSuccess) {
                _isSyncing = false;
                await processQueue(isManual: isManual);
                return;
              }
            }
            
            // Si es un error de red o de servidor (5xx), paramos la cola
            if (code == 0 || code >= 500) {
              hasNetworkError = true;
              break; 
            }
          }
          
          // Otros errores desconocidos: asumimos error de red/temporal y aplicamos backoff
          hasNetworkError = true;
          break; 
        }
      }

      if (hasNetworkError || hasItemError) {
        _applyBackoff();
        if (isManual || !_isManualInResultState) {
          if (isManual) _isManualInResultState = true;
          syncStatusNotifier.value = SyncStatus.error;
          if (isManual) _resetManualGuardAfterDelay();
        }
      } else {
        // Todo éxito: reset backoff
        _errorCount = 0;
        _nextRetryTime = null;
        
        if (isManual || !_isManualInResultState) {
          if (isManual) {
            _isManualInResultState = true;
            _lastManualSyncTime = DateTime.now();
          }
          syncStatusNotifier.value = SyncStatus.success;
          if (isManual) _resetManualGuardAfterDelay();
        }
      }

    } catch (e) {
      _applyBackoff();
      if (isManual || !_isManualInResultState) {
        if (isManual) _isManualInResultState = true;
        syncStatusNotifier.value = SyncStatus.error;
        if (isManual) _resetManualGuardAfterDelay();
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<_SyncResult> _executeSyncItem(PendingSync pending, Map<String, dynamic> data) async {
    bool success = false;
    
    // Dispatcher
    if (pending.collection == 'history') {
      success = await _syncHistory(pending, data);
    } else if (pending.collection == 'savings') {
      success = await _syncSavings(pending, data);
    } else if (pending.collection == 'settings') {
      success = await _syncSettings(pending, data);
    } else if (pending.collection == 'recurrent_expenses') {
      success = await _syncRecurrentExpenses(pending, data);
    } else if (pending.collection == 'shopping_list') {
      success = await _syncShoppingList(pending, data);
    } else if (pending.collection == 'tickets') {
      // El método de tickets puede devolver un resultado específico para archivos inexistentes
      return await _syncTickets(pending, data);
    } else if (pending.collection == 'debts_loans') {
      success = await _syncDebtsLoans(pending, data);
    } else if (pending.collection == 'user') {
      success = await _syncUser(pending, data);
    }

    return success ? _SyncResult.success : _SyncResult.retry;
  }

  void resetSyncStatus() {
    syncStatusNotifier.value = SyncStatus.idle;
  }

  void _resetManualGuardAfterDelay() {
    Future.delayed(const Duration(seconds: 4), () {
      _isManualInResultState = false;
      if (syncStatusNotifier.value != SyncStatus.syncing) {
        syncStatusNotifier.value = SyncStatus.idle;
      }
    });
  }

  void _applyBackoff() {
    _errorCount++;
    final secondsToWait = min(5 * pow(3, _errorCount - 1).toInt(), 600);
    _nextRetryTime = DateTime.now().add(Duration(seconds: secondsToWait));
    debugPrint('⚠️ Error de sincronización ($_errorCount). Reintento en $secondsToWait segundos.');
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

  String _formatAmount(dynamic money) {
    if (money == null) return '0';
    final num val = money is num ? money : num.tryParse(money.toString()) ?? 0;
    // Si es entero, mostrar sin decimales. Si tiene decimales, mostrar 2 máximo.
    if (val == val.toInt()) return val.toInt().toString();
    return val.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  }

  // --- MÉTODOS DE SINCRONIZACIÓN ---

  Future<bool> _syncUser(PendingSync pending, Map<String, dynamic> data) async {
    if (pending.action == 'update_name') {
      final authService = getIt<AuthAppwrite>();
      return await authService.updateRemoteName(data['name'] ?? '');
    }
    return false;
  }

  Future<bool> _syncHistory(PendingSync pending, Map<String, dynamic> data) async {
    if (pending.action == 'create') {
      String? remoteImageId = data['remoteImageId'];
      final String? ticketId = data['ticketId'];

      if ((remoteImageId == null || remoteImageId.isEmpty) && ticketId != null) {
        final ticket = await _localDb.isar.localTicketItems.filter().ticketItemIdEqualTo(ticketId).findFirst();
        if (ticket != null && ticket.remoteImageId != null) {
          remoteImageId = ticket.remoteImageId;
        }
      }

      final double money = (data['money'] as num?)?.toDouble() ?? 0.0;
      debugPrint('⬆️ Sincronizando historial: ${data['name']} por ${_formatAmount(money)}');

      await _appwriteRepo.addHistory(
        documentId: pending.appwriteId!,
        userId: data['userId'] ?? '',
        name: data['name'] ?? '',
        money: money,
        isIncome: data['isIncome'] ?? false,
        currentDate: data['currentDate'] ?? data['date'] ?? '',
        currentHour: data['currentHour'] ?? data['hour'] ?? '',
        month: data['month'] ?? '',
        year: data['year'] ?? 0,
        isRecurrent: data['isRecurrent'] ?? false,
        category: data['category'] ?? (data['isIncome'] == true ? 'otro' : 'general'),
        ticketId: data['ticketId'],
        imagePath: data['imagePath'],
        remoteImageId: remoteImageId,
        isTransferred: data['isTransferred'] ?? false,
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
      final double money = (data['money'] as num?)?.toDouble() ?? 0.0;
      debugPrint('⬆️ Sincronizando ahorro: ${_formatAmount(money)}');

      await _appwriteRepo.addSaving(
        documentId: pending.appwriteId!,
        userId: data['userId'] ?? '',
        money: money,
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

  Future<bool> _syncRecurrentExpenses(PendingSync pending, Map<String, dynamic> data) async {
    if (pending.action == 'create') {
      await _appwriteRepo.addRecurrentExpense(
        documentId: pending.appwriteId!,
        userId: data['userId'] ?? '',
        name: data['name'] ?? '',
        money: (data['money'] as num?)?.toDouble() ?? 0.0,
        day: data['day'],
        category: data['category'] ?? 'general',
        isActive: data['isActive'] ?? true,
        lastApplied: data['lastApplied'],
        frequency: data['frequency'] ?? 'monthly',
        startDate: DateTime.parse(data['startDate'] ?? DateTime.now().toIso8601String()),
        position: data['position'] ?? 0,
        includeInSummary: data['includeInSummary'] ?? true,
      );
      return true;
    } else if (pending.action == 'update') {
      await _appwriteRepo.updateRecurrentExpense(documentId: pending.appwriteId!, data: data);
      return true;
    } else if (pending.action == 'delete') {
      await _appwriteRepo.deleteRecurrentExpense(pending.appwriteId!);
      return true;
    }
    return false;
  }

  Future<bool> _syncShoppingList(PendingSync pending, Map<String, dynamic> data) async {
    if (pending.action == 'save') {
      try {
        await _appwriteRepo.updateShoppingItem(
          documentId: pending.appwriteId!, 
          data: {
            'name': data['name'],
            'amount': (data['amount'] as num?)?.toDouble() ?? 0.0,
            'category': data['category'],
            'isBought': data['isBought'],
            'position': data['position'],
            'quantity': data['quantity'] ?? 1,
          }
        );
      } catch (e) {
        await _appwriteRepo.addShoppingItem(
          documentId: pending.appwriteId!,
          userId: data['userId'] ?? '',
          name: data['name'] ?? '',
          amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
          category: data['category'] ?? 'general',
          isBought: data['isBought'] ?? false,
          position: data['position'] ?? 0,
          quantity: data['quantity'] ?? 1,
        );
      }
      return true;
    } else if (pending.action == 'delete') {
      await _appwriteRepo.deleteShoppingItem(pending.appwriteId!);
      return true;
    }
    return false;
  }

  Future<_SyncResult> _syncTickets(PendingSync pending, Map<String, dynamic> data) async {
    if (pending.action == 'save') {
      String? remoteImageId = data['remoteImageId'];
      final String? localPath = data['imagePath'];

      if ((remoteImageId == null || remoteImageId.isEmpty) && pending.appwriteId != null) {
        final localTicket = await _localDb.isar.localTicketItems.filter().ticketItemIdEqualTo(pending.appwriteId!).findFirst();
        if (localTicket != null && localTicket.remoteImageId != null && localTicket.remoteImageId!.isNotEmpty) {
          remoteImageId = localTicket.remoteImageId;
        }
      }

      if ((remoteImageId == null || remoteImageId.isEmpty) && localPath != null) {
        try {
          final appDir = await getApplicationDocumentsDirectory();
          final resolvedPath = localPath.contains('/')
              ? localPath
              : '${appDir.path}/$localPath';
          final file = File(resolvedPath);
          
          if (await file.exists()) {
            remoteImageId = await _appwriteRepo.uploadTicketImage(file);
            final isar = _localDb.isar;
            final localTicket = await isar.localTicketItems.filter().ticketItemIdEqualTo(pending.appwriteId!).findFirst();
            if (localTicket != null) {
              await isar.writeTxn(() async {
                localTicket.remoteImageId = remoteImageId;
                await isar.localTicketItems.put(localTicket);
              });
            }
          } else {
            debugPrint('❌ Archivo de ticket no encontrado en: $resolvedPath. Eliminando de la cola de sincronización.');
            // Según instrucciones: eliminar el ítem si el archivo no existe
            return _SyncResult.fatal;
          }
        } catch (e) {
          return _SyncResult.retry;
        }
      }

      final cleanData = Map<String, dynamic>.from(data);
      cleanData.remove('imagePath');
      cleanData['remoteImageId'] = remoteImageId;

      try {
        await _appwriteRepo.updateTicket(
          documentId: pending.appwriteId!, 
          data: cleanData,
        );
      } catch (e) {
        if (e is AppwriteException && e.code == 404) {
          await _appwriteRepo.addTicket(
            documentId: pending.appwriteId!,
            ticketItemId: cleanData['ticketItemId'] ?? pending.appwriteId!,
            userId: cleanData['userId'] ?? '',
            name: cleanData['name'] ?? '',
            amount: (cleanData['amount'] as num?)?.toDouble() ?? 0.0,
            date: cleanData['date'] ?? '',
            category: cleanData['category'] ?? 'general',
            position: cleanData['position'] ?? 0,
            isTransferred: cleanData['isTransferred'] ?? false,
            remoteImageId: remoteImageId,
          );
        } else {
          rethrow;
        }
      }
      return _SyncResult.success;
    } else if (pending.action == 'delete') {
      final String? remoteImageId = data['remoteImageId'];
      if (remoteImageId != null && remoteImageId.isNotEmpty) {
        try {
          await _appwriteRepo.deleteTicketImage(remoteImageId);
        } catch (_) {}
      }
      try {
        await _appwriteRepo.deleteTicket(pending.appwriteId!);
      } catch (_) {}
      return _SyncResult.success;
    }
    return _SyncResult.fatal;
  }

  Future<bool> _syncDebtsLoans(PendingSync pending, Map<String, dynamic> data) async {
    final remoteRepo = getIt<DebtLoanRepository>(instanceName: 'debt_remote');
    
    final debtLoan = DebtLoan(
      id: pending.appwriteId!,
      userId: data['userId'],
      name: data['name'],
      person: data['person'],
      totalAmount: (data['totalAmount'] as num).toDouble(),
      paidAmount: (data['paidAmount'] as num).toDouble(),
      date: data['date'] != null ? DateTime.parse(data['date']) : null,
      dueDate: data['dueDate'] != null ? DateTime.parse(data['dueDate']) : null,
      type: data['type'] == 'debt' ? DebtLoanType.debt : DebtLoanType.loan,
      category: data['category'] ?? 'general',
      isCompleted: data['isCompleted'] ?? false,
      isInstallment: data['isInstallment'] ?? false,
      totalInstallments: data['totalInstallments'],
      installmentAmount: data['installmentAmount'] != null ? (data['installmentAmount'] as num).toDouble() : null,
      recurrentExpenseId: data['recurrentExpenseId'],
    );

    if (pending.action == 'CREATE') {
      await remoteRepo.addDebtLoan(debtLoan);
      return true;
    } else if (pending.action == 'UPDATE') {
      await remoteRepo.updateDebtLoan(debtLoan);
      return true;
    } else if (pending.action == 'DELETE') {
      await remoteRepo.deleteDebtLoan(pending.appwriteId!);
      return true;
    }
    return false;
  }
}
