import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:ahorrapp/domain/repositories/i_recurrent_expense_repository.dart';
import 'package:appwrite/appwrite.dart';
import '../appwrite/appwrite_repository.dart';

class AppwriteRecurrentExpenseRepository implements IRecurrentExpenseRepository {
  final AppwriteRepository _dataSource = AppwriteRepository();

  @override
  Future<List<RecurrentExpense>> getRecurrentExpenses(String userId) async {
    final docs = await _dataSource.getRecurrentExpenses(userId);
    return docs.map((doc) => _mapToEntity(doc)).toList();
  }

  @override
  Future<void> saveRecurrentExpense(RecurrentExpense expense) async {
    try {
      // Intentamos crear el documento
      await _dataSource.addRecurrentExpense(
        documentId: expense.id,
        userId: expense.userId,
        name: expense.name,
        money: expense.amount,
        day: expense.day,
        category: expense.category,
        isActive: expense.isActive,
        lastApplied: expense.lastApplied,
      );
    } catch (e) {
      // Si el error es 409 (ya existe), procedemos a actualizar
      if (e is AppwriteException && e.code == 409) {
        await _dataSource.updateRecurrentExpense(
          documentId: expense.id,
          data: {
            'name': expense.name,
            'money': expense.amount,
            'day': expense.day,
            'category': expense.category,
            'isActive': expense.isActive,
            'lastApplied': expense.lastApplied,
          },
        );
      } else {
        // Si es otro error (red, permisos), lo lanzamos para que el Cubit lo capture
        rethrow;
      }
    }
  }

  @override
  Future<void> deleteRecurrentExpense(String id) async {
    await _dataSource.deleteRecurrentExpense(id);
  }

  @override
  Future<void> updateLastApplied(String id, String monthYear) async {
    await _dataSource.updateRecurrentExpense(
      documentId: id,
      data: {'lastApplied': monthYear},
    );
  }

  RecurrentExpense _mapToEntity(dynamic doc) {
    final data = doc.data;
    return RecurrentExpense(
      id: doc.$id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      amount: (data['money'] as num).toDouble(),
      day: data['day'], // Es int?
      category: data['category'] ?? 'general',
      isActive: data['isActive'] ?? true,
      lastApplied: data['lastApplied'],
    );
  }
}
