import 'package:ahorrapp/domain/entities/movement.dart';
import 'package:ahorrapp/domain/repositories/i_movement_repository.dart';
import '../local/local_db_service.dart';
import '../local/models/local_history.dart';

class IsarMovementRepository implements IMovementRepository {
  final LocalDbService _localDb = LocalDbService();

  @override
  Future<List<Movement>> getMovementsByMonth(String userId, String month, int year) async {
    final localItems = await _localDb.getHistoryByMonth(month, year);
    return localItems.map(_mapToMovement).toList();
  }

  @override
  Future<void> saveMovement(Movement movement) async {
    final localItem = LocalHistory()
      ..appwriteId = movement.id
      ..name = movement.name
      ..money = movement.amount
      ..isIncome = movement.isIncome
      ..type = _mapTypeToString(movement.type)
      ..currentDate = movement.date
      ..currentHour = movement.hour
      ..month = movement.month
      ..year = movement.year
      ..createdAt = movement.createdAt
      ..isSpent = movement.isSpent;

    await _localDb.saveHistoryItems([localItem]);
  }

  @override
  Future<void> deleteMovement(String id) async {
    await _localDb.deleteItemByAppwriteId(id);
  }

  @override
  Future<double> getGlobalBalance(String userId) async {
    return await _localDb.getTotalBalance(userId);
  }

  @override
  Future<void> updateGlobalBalance(String userId, double amount) async {
    await _localDb.saveTotalBalance(userId, amount);
  }

  @override
  Future<Map<String, dynamic>> syncAllData(String userId, Function(double) onProgress) async {
    // La sincronización total suele ser responsabilidad del repositorio de nube (Appwrite)
    // que vuelca en el local. No obstante, dejamos la firma por si Isar necesitara una lógica propia.
    throw UnimplementedError('La sincronización se gestiona desde el repositorio de nube.');
  }

  Movement _mapToMovement(LocalHistory local) {
    MovementType type = MovementType.expense;
    if (local.type == 'income') {
      type = MovementType.income;
    } else if (local.type == 'saving') {
      type = MovementType.saving;
    }

    return Movement(
      id: local.appwriteId,
      name: local.name,
      amount: local.money,
      type: type,
      isIncome: local.isIncome,
      date: local.currentDate,
      hour: local.currentHour,
      month: local.month,
      year: local.year,
      createdAt: local.createdAt,
      isSpent: local.isSpent,
    );
  }

  String _mapTypeToString(MovementType type) {
    switch (type) {
      case MovementType.income: return 'income';
      case MovementType.expense: return 'expense';
      case MovementType.saving: return 'saving';
    }
  }
}
