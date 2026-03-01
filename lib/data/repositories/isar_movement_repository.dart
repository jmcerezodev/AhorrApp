import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/domain/entities/movement.dart';
import 'package:ahorrapp/domain/repositories/i_movement_repository.dart';
import '../local/local_db_service.dart';
import '../local/models/local_history.dart';
import '../local/models/local_saving.dart';

class IsarMovementRepository implements IMovementRepository {
  final LocalDbService _localDb;

  IsarMovementRepository({LocalDbService? localDb}) 
    : _localDb = localDb ?? getIt<LocalDbService>();

  @override
  Future<List<Movement>> getMovementsByMonth(String userId, String month, int year) async {
    final localHistory = await _localDb.getHistoryByMonth(month, year);
    final localSavings = await _localDb.getSavingsByMonth(month, year);

    final List<Movement> movements = [];

    for (var item in localHistory) {
      movements.add(_mapHistoryToMovement(item));
    }

    for (var item in localSavings) {
      movements.add(_mapSavingToMovement(item));
    }

    movements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return movements;
  }

  @override
  Future<void> saveMovement(Movement movement) async {
    final String uid = Preferences.uId; // OBTENEMOS EL ID REAL DEL USUARIO

    if (movement.type == MovementType.saving) {
      final localSaving = LocalSaving()
        ..appwriteId = movement.id
        ..userId = uid // CORREGIDO: Usamos el UID real
        ..money = movement.amount
        ..month = movement.month
        ..year = movement.year
        ..description = movement.name
        ..createdAt = movement.createdAt
        ..isSpent = movement.isSpent;
      
      await _localDb.saveSavingItems([localSaving]);
    } else {
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
        ..createdAt = movement.createdAt;

      await _localDb.saveHistoryItems([localItem]);
    }
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
    throw UnimplementedError('La sincronización se gestiona desde el repositorio de nube.');
  }

  Movement _mapHistoryToMovement(LocalHistory local) {
    return Movement(
      id: local.appwriteId,
      name: local.name,
      amount: local.money,
      type: local.isIncome ? MovementType.income : MovementType.expense,
      isIncome: local.isIncome,
      date: local.currentDate,
      hour: local.currentHour,
      month: local.month,
      year: local.year,
      createdAt: local.createdAt,
    );
  }

  Movement _mapSavingToMovement(LocalSaving local) {
    return Movement(
      id: local.appwriteId,
      name: local.description,
      amount: local.money,
      type: MovementType.saving,
      isIncome: false,
      date: "${local.createdAt.day}/${local.createdAt.month}/${local.createdAt.year}",
      hour: "${local.createdAt.hour}:${local.createdAt.minute}",
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
