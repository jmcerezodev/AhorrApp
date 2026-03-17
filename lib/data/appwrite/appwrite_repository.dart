import 'dart:io';
import 'dart:typed_data';
import 'package:ahorrapp/core/config/env.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:uuid/uuid.dart';
import '../../core/appwrite/appwrite_service.dart';

class AppwriteRepository {
  final Databases _databases = AppwriteService().databases;
  final Account _account = AppwriteService().account;
  final Storage _storage = AppwriteService().storage;
  
  final String _databaseId = Env.appwriteDatabaseId;
  final String _historyId = Env.appwriteHistoryCollectionId;
  final String _savingsId = Env.appwriteSavingsCollectionId;
  final String _recurrentId = Env.appwriteRecurrentExpensesCollectionId;
  final String _shoppingId = Env.appwriteShoppingListCollectionId;
  final String _templatesId = Env.appwriteShoppingTemplatesCollectionId;
  final String _ticketsId = Env.appwriteTicketsCollectionId;
  final String _debtsId = Env.debtsLoansCollectionId;
  final String _ticketsBucketId = Env.appwriteTicketsBucketId;

  // --- STORAGE ---

  Future<String> uploadTicketImage(File file) async {
    final String fileId = const Uuid().v4().replaceAll('-', '');
    
    try {
      final fileName = 'ticket_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _storage.createFile(
        bucketId: _ticketsBucketId,
        fileId: fileId,
        file: InputFile.fromPath(path: file.path, filename: fileName),
      );
      return fileId;
    } catch (e) {
      if (e.toString().contains("'Null' is not a subtype of type 'bool'")) {
        return fileId;
      }
      rethrow;
    }
  }

  Future<void> deleteTicketImage(String fileId) async {
    try {
      await _storage.deleteFile(bucketId: _ticketsBucketId, fileId: fileId);
    } catch (_) {}
  }

  /// Descarga el contenido binario de una imagen de ticket desde Appwrite Storage.
  /// Se usa para recuperar imágenes locales tras una reinstalación.
  Future<Uint8List> downloadTicketImage(String fileId) async {
    return await _storage.getFileDownload(
      bucketId: _ticketsBucketId,
      fileId: fileId,
    );
  }

  // --- PREFERENCIAS DE USUARIO ---

  Future<Map<String, dynamic>> getUserPrefs() async {
    final user = await _account.get();
    return user.prefs.data;
  }

  Future<void> updatePrefs(Map<String, dynamic> prefs) async {
    await _account.updatePrefs(prefs: prefs);
  }

  // --- BALANCE GLOBAL ---
  
  Future<double> getTotalBalance() async {
    try {
      final user = await _account.get();
      return (user.prefs.data['total_balance'] ?? -999999.0).toDouble();
    } catch (e) {
      return 0.0;
    }
  }

  Future<void> updateTotalBalance(double newBalance) async {
    try {
      await _account.updatePrefs(prefs: {'total_balance': newBalance});
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> syncFullData(String userId, Function(double) onProgress) async {
    double totalIncomes = 0;
    double totalExpenses = 0;
    List<models.Document> allHistory = [];
    List<models.Document> allSavings = [];
    List<models.Document> allRecurrent = [];
    List<models.Document> allShopping = [];
    List<models.Document> allTemplates = [];
    List<models.Document> allTickets = [];
    List<models.Document> allDebts = [];
    
    try {
      final historyInfo = await _databases.listDocuments(databaseId: _databaseId, collectionId: _historyId, queries: [Query.equal('userId', [userId]), Query.limit(1)]);
      final savingsInfo = await _databases.listDocuments(databaseId: _databaseId, collectionId: _savingsId, queries: [Query.equal('userId', [userId]), Query.limit(1)]);
      final recurrentInfo = await _databases.listDocuments(databaseId: _databaseId, collectionId: _recurrentId, queries: [Query.equal('userId', [userId]), Query.limit(1)]);
      final ticketsInfo = await _databases.listDocuments(databaseId: _databaseId, collectionId: _ticketsId, queries: [Query.equal('userId', [userId]), Query.limit(1)]);
      final debtsInfo = await _databases.listDocuments(databaseId: _databaseId, collectionId: _debtsId, queries: [Query.equal('userId', [userId]), Query.limit(1)]);
      
      final int totalDocsCount = historyInfo.total + savingsInfo.total + recurrentInfo.total + ticketsInfo.total + debtsInfo.total;
      
      if (totalDocsCount == 0) {
        await updateTotalBalance(0.0);
        return {
          'balance': 0.0, 
          'history': [], 
          'savings': [], 
          'recurrent': [], 
          'shopping': [], 
          'templates': [],
          'tickets': [],
          'debts': [],
          'savingGoal': 0.0
        };
      }

      int processed = 0;

      // 1. Procesar Movimientos
      bool hasMore = true;
      String? lastId;
      while (hasMore) {
        final response = await _databases.listDocuments(
          databaseId: _databaseId,
          collectionId: _historyId,
          queries: [Query.equal('userId', [userId]), Query.limit(100), Query.orderAsc('\$id'), if (lastId != null) Query.cursorAfter(lastId)],
        );
        for (var doc in response.documents) {
          final double amount = (doc.data['money'] as num).toDouble().abs();
          if (doc.data['isIncome'] == true) totalIncomes += amount; else totalExpenses += amount;
          allHistory.add(doc);
        }
        processed += response.documents.length;
        onProgress((processed / totalDocsCount) * 0.2);
        if (response.documents.length < 100) hasMore = false; else lastId = response.documents.last.$id;
      }

      // 2. Procesar Ahorros
      hasMore = true;
      lastId = null;
      while (hasMore) {
        final response = await _databases.listDocuments(
          databaseId: _databaseId,
          collectionId: _savingsId,
          queries: [Query.equal('userId', [userId]), Query.limit(100), Query.orderAsc('\$id'), if (lastId != null) Query.cursorAfter(lastId)],
        );
        allSavings.addAll(response.documents);
        processed += response.documents.length;
        onProgress((processed / totalDocsCount) * 0.4);
        if (response.documents.length < 100) hasMore = false; else lastId = response.documents.last.$id;
      }

      // 3. Procesar Recurrentes
      hasMore = true;
      lastId = null;
      while (hasMore) {
        final response = await _databases.listDocuments(
          databaseId: _databaseId,
          collectionId: _recurrentId,
          queries: [Query.equal('userId', [userId]), Query.limit(100), Query.orderAsc('\$id'), if (lastId != null) Query.cursorAfter(lastId)],
        );
        allRecurrent.addAll(response.documents);
        processed += response.documents.length;
        onProgress((processed / totalDocsCount) * 0.6);
        if (response.documents.length < 100) hasMore = false; else lastId = response.documents.last.$id;
      }

      // 4. Procesar Deudas
      hasMore = true;
      lastId = null;
      while (hasMore) {
        final response = await _databases.listDocuments(
          databaseId: _databaseId,
          collectionId: _debtsId,
          queries: [Query.equal('userId', [userId]), Query.limit(100), Query.orderAsc('\$id'), if (lastId != null) Query.cursorAfter(lastId)],
        );
        allDebts.addAll(response.documents);
        processed += response.documents.length;
        onProgress((processed / totalDocsCount) * 0.8);
        if (response.documents.length < 100) hasMore = false; else lastId = response.documents.last.$id;
      }

      // 5. Procesar Tickets
      hasMore = true;
      lastId = null;
      while (hasMore) {
        final response = await _databases.listDocuments(
          databaseId: _databaseId,
          collectionId: _ticketsId,
          queries: [Query.equal('userId', [userId]), Query.limit(100), Query.orderAsc('\$id'), if (lastId != null) Query.cursorAfter(lastId)],
        );
        allTickets.addAll(response.documents);
        processed += response.documents.length;
        onProgress((processed / totalDocsCount) * 0.95);
        if (response.documents.length < 100) hasMore = false; else lastId = response.documents.last.$id;
      }

      // 6. Procesar Compra y Plantillas
      try {
        final shopResp = await _databases.listDocuments(databaseId: _databaseId, collectionId: _shoppingId, queries: [Query.equal('userId', [userId]), Query.limit(100)]);
        allShopping.addAll(shopResp.documents);
        
        final tempResp = await _databases.listDocuments(databaseId: _databaseId, collectionId: _templatesId, queries: [Query.equal('userId', [userId]), Query.limit(100)]);
        allTemplates.addAll(tempResp.documents);
      } catch (_) {}

      final double finalBalance = totalIncomes - totalExpenses;
      await updateTotalBalance(finalBalance);
      
      final userPrefs = await getUserPrefs();
      final double savingGoal = (userPrefs['savingGoal'] ?? 0.0).toDouble();

      onProgress(1.0);

      return {
        'balance': finalBalance,
        'history': allHistory,
        'savings': allSavings,
        'recurrent': allRecurrent,
        'shopping': allShopping,
        'templates': allTemplates,
        'tickets': allTickets,
        'debts': allDebts,
        'savingGoal': savingGoal,
      };
    } catch (e) {
      rethrow;
    }
  }

  // --- TICKETS ---

  Future<List<models.Document>> getTickets(String userId) async {
    return (await _databases.listDocuments(
      databaseId: _databaseId,
      collectionId: _ticketsId,
      queries: [Query.equal('userId', [userId]), Query.orderAsc('position')],
    )).documents;
  }

  Future<models.Document> addTicket({
    required String documentId,
    required String ticketItemId,
    required String userId,
    required String name,
    required double amount,
    required String date,
    required String category,
    required int position,
    required bool isTransferred,
    String? remoteImageId,
  }) async {
    return await _databases.createDocument(
      databaseId: _databaseId,
      collectionId: _ticketsId,
      documentId: documentId,
      data: {
        'ticketItemId': ticketItemId,
        'userId': userId,
        'name': name,
        'amount': amount,
        'date': date,
        'category': category,
        'position': position,
        'isTransferred': isTransferred,
        'remoteImageId': remoteImageId,
      },
    );
  }

  Future<models.Document> updateTicket({required String documentId, required Map<String, dynamic> data}) async {
    return await _databases.updateDocument(
      databaseId: _databaseId,
      collectionId: _ticketsId,
      documentId: documentId,
      data: data,
    );
  }

  Future<void> deleteTicket(String documentId) async {
    await _databases.deleteDocument(databaseId: _databaseId, collectionId: _ticketsId, documentId: documentId);
  }

  // --- PLANTILLAS DE COMPRA ---

  Future<List<models.Document>> getShoppingTemplates(String userId) async {
    return (await _databases.listDocuments(
      databaseId: _databaseId,
      collectionId: _templatesId,
      queries: [Query.equal('userId', [userId]), Query.orderDesc('\$createdAt')],
    )).documents;
  }

  Future<models.Document> addShoppingTemplate({required String documentId, required String userId, required String name, required String itemsJson}) async {
    return await _databases.createDocument(
      databaseId: _databaseId, 
      collectionId: _templatesId, 
      documentId: documentId, 
      data: {'userId': userId, 'name': name, 'itemsJson': itemsJson}
    );
  }

  Future<void> deleteShoppingTemplate(String documentId) async {
    await _databases.deleteDocument(databaseId: _databaseId, collectionId: _templatesId, documentId: documentId);
  }

  // --- LISTA DE LA COMPRA ---

  Future<List<models.Document>> getShoppingList(String userId) async {
    return (await _databases.listDocuments(
      databaseId: _databaseId,
      collectionId: _shoppingId,
      queries: [Query.equal('userId', [userId]), Query.limit(100)],
    )).documents;
  }

  Future<models.Document> addShoppingItem({required String documentId, required String userId, required String name, required double amount, String category = 'general', bool isBought = false, int position = 0, int quantity = 1}) async {
    return await _databases.createDocument(databaseId: _databaseId, collectionId: _shoppingId, documentId: documentId, data: {'userId': userId, 'name': name, 'amount': amount, 'category': category, 'isBought': isBought, 'position': position, 'quantity': quantity});
  }

  Future<models.Document> updateShoppingItem({required String documentId, required Map<String, dynamic> data}) async {
    return await _databases.updateDocument(databaseId: _databaseId, collectionId: _shoppingId, documentId: documentId, data: data);
  }

  Future<void> deleteShoppingItem(String documentId) async => await _databases.deleteDocument(databaseId: _databaseId, collectionId: _shoppingId, documentId: documentId);

  // --- CONSULTAS FILTRADAS ---
  
  Future<List<models.Document>> getHistoryByMonth(String userId, String month, int year) async {
    return (await _databases.listDocuments(
      databaseId: _databaseId,
      collectionId: _historyId,
      queries: [Query.equal('userId', [userId]), Query.equal('month', [month]), Query.equal('year', [year]), Query.orderDesc('\$createdAt'), Query.limit(100)],
    )).documents;
  }

  Future<List<models.Document>> getSavingsByMonth(String userId, String month, int year) async {
    try {
      return (await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _savingsId,
        queries: [Query.equal('userId', [userId]), Query.equal('month', [month]), Query.equal('year', [year]), Query.orderDesc('\$createdAt')],
      )).documents;
    } catch (e) {
      return (await _databases.listDocuments(databaseId: _databaseId, collectionId: _savingsId, queries: [Query.equal('userId', [userId]), Query.orderDesc('\$createdAt')])).documents;
    }
  }

  Future<List<models.Document>> getRecurrentExpenses(String userId) async {
    return (await _databases.listDocuments(
      databaseId: _databaseId,
      collectionId: _recurrentId,
      queries: [Query.equal('userId', [userId]), Query.limit(100)],
    )).documents;
  }

  // --- ACCIONES ---

  Future<models.Document> updateHistory({required String documentId, required Map<String, dynamic> data}) async {
    return await _databases.updateDocument(databaseId: _databaseId, collectionId: _historyId, documentId: documentId, data: data);
  }

  Future<models.Document> addHistory({
    required String documentId, 
    required String userId, 
    required String name, 
    required double money, 
    required bool isIncome, 
    required String currentDate, 
    required String currentHour, 
    required String month, 
    required int year, 
    bool isRecurrent = false, 
    String category = 'general',
    String? ticketId,
    String? imagePath,
    String? remoteImageId,
    bool isTransferred = false,
  }) async {
    return await _databases.createDocument(
      databaseId: _databaseId, 
      collectionId: _historyId, 
      documentId: documentId, 
      data: {
        'userId': userId, 
        'name': name, 
        'money': money, 
        'isIncome': isIncome, 
        'currentDate': currentDate, 
        'currentHour': currentHour, 
        'month': month, 
        'year': year, 
        'isRecurrent': isRecurrent, 
        'category': category,
        'ticketId': ticketId,
        'imagePath': imagePath,
        'remoteImageId': remoteImageId,
        'isTransferred': isTransferred,
      }
    );
  }

  Future<models.Document> addSaving({required String documentId, required String userId, required double money, required String month, required int year, String? description, bool isSpent = false}) async {
    return await _databases.createDocument(databaseId: _databaseId, collectionId: _savingsId, documentId: documentId, data: {'userId': userId, 'money': money, 'month': month, 'year': year, 'description': description ?? 'Aportación de ahorro', 'isSpent': isSpent});
  }

  Future<models.Document> addRecurrentExpense({required String documentId, required String userId, required String name, required double money, int? day, String category = 'general', bool isActive = true, String? lastApplied, String frequency = 'monthly', required DateTime startDate, int position = 0, bool includeInSummary = true, bool isIncome = false}) async {
    return await _databases.createDocument(databaseId: _databaseId, collectionId: _recurrentId, documentId: documentId, data: {'userId': userId, 'name': name, 'money': money, 'day': day, 'category': category, 'isActive': isActive, 'lastApplied': lastApplied, 'frequency': frequency, 'startDate': startDate.toIso8601String(), 'position': position, 'includeInSummary': includeInSummary, 'isIncome': isIncome});
  }

  Future<models.Document> updateRecurrentExpense({required String documentId, required Map<String, dynamic> data}) async {
    return await _databases.updateDocument(
      databaseId: _databaseId, 
      collectionId: _recurrentId, 
      documentId: documentId, 
      data: data
    );
  }

  Future<void> deleteHistory(String documentId) async => await _databases.deleteDocument(databaseId: _databaseId, collectionId: _historyId, documentId: documentId);
  Future<void> deleteSaving(String documentId) async => await _databases.deleteDocument(databaseId: _databaseId, collectionId: _savingsId, documentId: documentId);
  Future<void> deleteRecurrentExpense(String documentId) async => await _databases.deleteDocument(databaseId: _databaseId, collectionId: _recurrentId, documentId: documentId);
  
  Future<models.Document> updateSaving({required String documentId, Map<String, dynamic>? data, double? money}) async {
    return await _databases.updateDocument(
      databaseId: _databaseId, 
      collectionId: _savingsId, 
      documentId: documentId, 
      data: data ?? {'money': money}
    );
  }

  Future<int> getTotalDocsToDelete(String userId) async {
    final historyInfo = await _databases.listDocuments(databaseId: _databaseId, collectionId: _historyId, queries: [Query.equal('userId', [userId]), Query.limit(1)]);
    final savingsInfo = await _databases.listDocuments(databaseId: _databaseId, collectionId: _savingsId, queries: [Query.equal('userId', [userId]), Query.limit(1)]);
    final recurrentInfo = await _databases.listDocuments(databaseId: _databaseId, collectionId: _recurrentId, queries: [Query.equal('userId', [userId]), Query.limit(1)]);
    final ticketsInfo = await _databases.listDocuments(databaseId: _databaseId, collectionId: _ticketsId, queries: [Query.equal('userId', [userId]), Query.limit(1)]);
    return historyInfo.total + savingsInfo.total + recurrentInfo.total + ticketsInfo.total;
  }

  Future<int> deleteAllHistory(String userId, {Function(int)? onDeleted}) async {
    int deletedCount = 0;
    bool hasMore = true;
    while (hasMore) {
      final response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _historyId,
        queries: [Query.equal('userId', [userId]), Query.limit(100)],
      );
      if (response.documents.isEmpty) {
        hasMore = false;
      } else {
        for (var doc in response.documents) {
          await deleteHistory(doc.$id);
          deletedCount++;
          if (onDeleted != null) onDeleted(deletedCount);
        }
      }
    }
    return deletedCount;
  }

  Future<int> deleteAllSavings(String userId, {Function(int)? onDeleted}) async {
    int deletedCount = 0;
    bool hasMore = true;
    while (hasMore) {
      final response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _savingsId,
        queries: [Query.equal('userId', [userId]), Query.limit(100)],
      );
      if (response.documents.isEmpty) {
        hasMore = false;
      } else {
        for (var doc in response.documents) {
          await deleteSaving(doc.$id);
          deletedCount++;
          if (onDeleted != null) onDeleted(deletedCount);
        }
      }
    }
    return deletedCount;
  }

  Future<int> deleteAllRecurrentExpenses(String userId, {Function(int)? onDeleted}) async {
    int deletedCount = 0;
    bool hasMore = true;
    while (hasMore) {
      final response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _recurrentId,
        queries: [Query.equal('userId', [userId]), Query.limit(100)],
      );
      if (response.documents.isEmpty) {
        hasMore = false;
      } else {
        for (var doc in response.documents) {
          await deleteRecurrentExpense(doc.$id);
          deletedCount++;
          if (onDeleted != null) onDeleted(deletedCount);
        }
      }
    }
    return deletedCount;
  }

  Future<int> deleteAllTickets(String userId, {Function(int)? onDeleted, int currentTotalDeleted = 0}) async {
    int deletedCount = 0;
    bool hasMore = true;
    while (hasMore) {
      final response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _ticketsId,
        queries: [Query.equal('userId', [userId]), Query.limit(100)],
      );
      if (response.documents.isEmpty) {
        hasMore = false;
      } else {
        for (var doc in response.documents) {
          await deleteTicket(doc.$id);
          deletedCount++;
          if (onDeleted != null) onDeleted(currentTotalDeleted + deletedCount);
        }
      }
    }
    return deletedCount;
  }

  Future<void> deleteAllSavingsSync(String userId) async {
    final savings = await (await _databases.listDocuments(databaseId: _databaseId, collectionId: _savingsId, queries: [Query.equal('userId', [userId]), Query.limit(1000)])).documents;
    for (var doc in savings) {
      await deleteSaving(doc.$id);
    }
  }
}
