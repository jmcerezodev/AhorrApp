import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/network/connectivity_service.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/data/local/models/pending_sync.dart';
import 'package:ahorrapp/data/local/models/local_ticket_item.dart';
import 'package:ahorrapp/data/local/models/local_history.dart';
import 'package:ahorrapp/domain/repositories/debt_loan_repository.dart';
import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:appwrite/appwrite.dart';
import 'package:isar/isar.dart';

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
          } else if (pending.collection == 'recurrent_expenses') {
            success = await _syncRecurrentExpenses(pending, data);
          } else if (pending.collection == 'shopping_list') {
            success = await _syncShoppingList(pending, data);
          } else if (pending.collection == 'tickets') {
            success = await _syncTickets(pending, data);
          } else if (pending.collection == 'debts_loans') {
            success = await _syncDebtsLoans(pending, data);
          }

          if (success) {
            await _localDb.deletePendingSync(pending.id);
          }
        } catch (e) {
          if (e is AppwriteException && (e.code == 401 || e.code == 403)) {
            final reauthSuccess = await _attemptSilentLogin();
            if (reauthSuccess) {
              _isSyncing = false;
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
      String? remoteImageId = data['remoteImageId'];
      final String? ticketId = data['ticketId'];

      if ((remoteImageId == null || remoteImageId.isEmpty) && ticketId != null) {
        final ticket = await _localDb.isar.localTicketItems.filter().ticketItemIdEqualTo(ticketId).findFirst();
        if (ticket != null && ticket.remoteImageId != null) {
          remoteImageId = ticket.remoteImageId;
        }
      }

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

  Future<bool> _syncTickets(PendingSync pending, Map<String, dynamic> data) async {
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
          final file = File(localPath);
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
          }
        } catch (e) {
          return false;
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
      }
      return true;
    } else if (pending.action == 'delete') {
      final String? remoteImageId = data['remoteImageId'];
      if (remoteImageId != null && remoteImageId.isNotEmpty) {
        await _appwriteRepo.deleteTicketImage(remoteImageId);
      }
      try {
        await _appwriteRepo.deleteTicket(pending.appwriteId!);
      } catch (_) {}
      return true;
    }
    return false;
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
