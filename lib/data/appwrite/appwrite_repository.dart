import 'package:ahorrapp/core/config/env.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import '../../core/appwrite/appwrite_service.dart';

class AppwriteRepository {
  final Databases _databases = AppwriteService().databases;
  
  final String _databaseId = Env.appwriteDatabaseId;
  final String _historyId = Env.appwriteHistoryCollectionId;
  final String _savingsId = Env.appwriteSavingsCollectionId;

  // --- HISTORIAL ---
  Future<List<Document>> getHistory(String userId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _historyId,
        queries: [
          Query.equal('userId', [userId]),
          Query.orderDesc('currentDate'),
        ],
      );
      return response.documents;
    } catch (e) {
      rethrow;
    }
  }

  Future<Document> addHistory({
    required String userId,
    required String name,
    required double money,
    required bool isIncome,
    required String currentDate,
    required String currentHour,
    required String month,
    required int year,
  }) async {
    try {
      return await _databases.createDocument(
        databaseId: _databaseId,
        collectionId: _historyId,
        documentId: ID.unique(),
        data: {
          'userId': userId,
          'name': name,
          'money': money,
          'isIncome': isIncome,
          'currentDate': currentDate,
          'currentHour': currentHour,
          'month': month,
          'year': year,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteHistory(String documentId) async {
    try {
      await _databases.deleteDocument(
        databaseId: _databaseId,
        collectionId: _historyId,
        documentId: documentId,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Document> updateHistory({
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      return await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: _historyId,
        documentId: documentId,
        data: data,
      );
    } catch (e) {
      rethrow;
    }
  }

  // --- AHORROS ---
  Future<List<Document>> getSavings(String userId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _savingsId,
        queries: [
          Query.equal('userId', [userId]),
          Query.orderDesc('\$createdAt'),
        ],
      );
      return response.documents;
    } catch (e) {
      rethrow;
    }
  }

  Future<Document> addSaving({
    required String userId,
    required double money,
    String? description,
  }) async {
    try {
      return await _databases.createDocument(
        databaseId: _databaseId,
        collectionId: _savingsId,
        documentId: ID.unique(),
        data: {
          'userId': userId,
          'money': money,
          'description': description ?? 'Aportación de ahorro',
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSaving(String documentId) async {
    try {
      await _databases.deleteDocument(
        databaseId: _databaseId,
        collectionId: _savingsId,
        documentId: documentId,
      );
    } catch (e) {
      rethrow;
    }
  }

  // NUEVO: Método para editar una aportación específica
  Future<Document> updateSaving({
    required String documentId,
    required double money,
  }) async {
    try {
      return await _databases.updateDocument(
        databaseId: _databaseId,
        collectionId: _savingsId,
        documentId: documentId,
        data: {
          'money': money,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAllSavings(String userId) async {
    try {
      final savings = await getSavings(userId);
      for (var doc in savings) {
        await deleteSaving(doc.$id);
      }
    } catch (e) {
      rethrow;
    }
  }
}
