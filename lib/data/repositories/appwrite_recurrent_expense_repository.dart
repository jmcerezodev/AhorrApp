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
      await _dataSource.addRecurrentExpense(
        documentId: expense.id,
        userId: expense.userId,
        name: expense.name,
        money: expense.amount,
        day: expense.day,
        category: expense.category,
        isActive: expense.isActive,
        lastApplied: expense.lastApplied,
        frequency: _mapFromDomainFrequency(expense.frequency),
        startDate: expense.startDate,
        position: expense.position,
        includeInSummary: expense.includeInSummary,
        isIncome: expense.isIncome, // NUEVO
      );
    } catch (e) {
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
            'frequency': _mapFromDomainFrequency(expense.frequency),
            'startDate': expense.startDate.toIso8601String(),
            'position': expense.position,
            'includeInSummary': expense.includeInSummary,
            'isIncome': expense.isIncome, // NUEVO
          },
        );
      } else {
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
      day: data['day'],
      category: data['category'] ?? 'general',
      isActive: data['isActive'] ?? true,
      lastApplied: data['lastApplied'],
      frequency: _mapToDomainFrequency(data['frequency'] ?? 'monthly'),
      startDate: DateTime.parse(data['startDate'] ?? DateTime.now().toIso8601String()),
      position: data['position'] ?? 0,
      includeInSummary: data['includeInSummary'] ?? true,
      isIncome: data['isIncome'] ?? false, // NUEVO
    );
  }

  String _mapFromDomainFrequency(RecurrentFrequency frequency) {
    switch (frequency) {
      case RecurrentFrequency.monthly: return 'monthly';
      case RecurrentFrequency.quarterly: return 'quarterly';
      case RecurrentFrequency.semiAnnually: return 'semiAnnually';
      case RecurrentFrequency.annually: return 'annually';
    }
  }

  RecurrentFrequency _mapToDomainFrequency(String frequency) {
    switch (frequency) {
      case 'monthly': return RecurrentFrequency.monthly;
      case 'quarterly': return RecurrentFrequency.quarterly;
      case 'semiAnnually': return RecurrentFrequency.semiAnnually;
      case 'annually': return RecurrentFrequency.annually;
      default: return RecurrentFrequency.monthly;
    }
  }
}
