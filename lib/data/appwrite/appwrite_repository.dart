import 'package:ahorrapp/core/config/env.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import '../../core/appwrite/appwrite_service.dart';

class AppwriteRepository {
  final Databases _databases = AppwriteService().databases;
  
  // Usamos las variables de entorno centralizadas
  final String _databaseId = Env.appwriteDatabaseId;
  final String _collectionId = Env.appwriteHistoryCollectionId;

  Future<List<Document>> getHistory(String userId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _collectionId,
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
        collectionId: _collectionId,
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
        collectionId: _collectionId,
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
        collectionId: _collectionId,
        documentId: documentId,
        data: data,
      );
    } catch (e) {
      rethrow;
    }
  }
}
