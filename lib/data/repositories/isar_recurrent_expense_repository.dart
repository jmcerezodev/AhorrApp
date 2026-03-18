import 'package:isar/isar.dart';
import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/data/local/models/local_recurrent_expense.dart';
import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:ahorrapp/domain/repositories/i_recurrent_expense_repository.dart';

class IsarRecurrentExpenseRepository implements IRecurrentExpenseRepository {
  final LocalDbService _localDb = getIt<LocalDbService>();

  @override
  Future<List<RecurrentExpense>> getRecurrentExpenses(String userId) async {
    final localItems = await _localDb.getRecurrentExpenses(userId);
    // Ordenamos por posición antes de mapear
    final sortedItems = [...localItems]..sort((a, b) => a.position.compareTo(b.position));
    return sortedItems.map((e) => _mapToEntity(e)).toList();
  }

  @override
  Future<void> saveRecurrentExpense(RecurrentExpense expense) async {
    final isar = _localDb.isar;
    
    final existingItem = await isar.localRecurrentExpenses
        .filter()
        .appwriteIdEqualTo(expense.id)
        .findFirst();

    final localItem = LocalRecurrentExpense()
      ..id = existingItem?.id ?? Isar.autoIncrement
      ..appwriteId = expense.id
      ..userId = expense.userId
      ..name = expense.name
      ..money = expense.amount
      ..day = expense.day
      ..category = expense.category
      ..isActive = expense.isActive
      ..lastApplied = expense.lastApplied
      ..frequency = _mapToLocalFrequency(expense.frequency)
      ..startDate = expense.startDate
      ..position = expense.position
      ..includeInSummary = expense.includeInSummary
      ..isIncome = expense.isIncome 
      ..createdAt = existingItem?.createdAt ?? DateTime.now();

    await _localDb.saveRecurrentExpenses([localItem]);
  }

  @override
  Future<void> deleteRecurrentExpense(String id) async {
    await _localDb.deleteRecurrentExpenseByAppwriteId(id);
  }

  @override
  Future<void> updateLastApplied(String id, String monthYear) async {
    final isar = _localDb.isar;
    await isar.writeTxn(() async {
      final item = await isar.localRecurrentExpenses.filter().appwriteIdEqualTo(id).findFirst();
      if (item != null) {
        item.lastApplied = monthYear;
        await isar.localRecurrentExpenses.put(item);
      }
    });
  }

  RecurrentExpense _mapToEntity(LocalRecurrentExpense local) {
    return RecurrentExpense(
      id: local.appwriteId,
      userId: local.userId,
      name: local.name,
      amount: local.money,
      day: local.day,
      category: local.category,
      isActive: local.isActive,
      lastApplied: local.lastApplied,
      frequency: _mapToDomainFrequency(local.frequency),
      startDate: local.startDate,
      position: local.position,
      includeInSummary: local.includeInSummary,
      isIncome: local.isIncome,
    );
  }

  LocalRecurrentFrequency _mapToLocalFrequency(RecurrentFrequency frequency) {
    switch (frequency) {
      case RecurrentFrequency.monthly: return LocalRecurrentFrequency.monthly;
      case RecurrentFrequency.quarterly: return LocalRecurrentFrequency.quarterly;
      case RecurrentFrequency.semiAnnually: return LocalRecurrentFrequency.semiAnnually;
      case RecurrentFrequency.annually: return LocalRecurrentFrequency.annually;
    }
  }

  RecurrentFrequency _mapToDomainFrequency(LocalRecurrentFrequency local) {
    switch (local) {
      case LocalRecurrentFrequency.monthly: return RecurrentFrequency.monthly;
      case LocalRecurrentFrequency.quarterly: return RecurrentFrequency.quarterly;
      case LocalRecurrentFrequency.semiAnnually: return RecurrentFrequency.semiAnnually;
      case LocalRecurrentFrequency.annually: return RecurrentFrequency.annually;
    }
  }
}
