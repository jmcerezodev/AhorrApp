import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/domain/entities/movement.dart';
import 'package:ahorrapp/domain/repositories/i_movement_repository.dart';
import '../appwrite/appwrite_repository.dart';

class AppwriteMovementRepository implements IMovementRepository {
  final AppwriteRepository _dataSource = AppwriteRepository();

  @override
  Future<List<Movement>> getMovementsByMonth(String userId, String month, int year) async {
    final historyDocs = await _dataSource.getHistoryByMonth(userId, month, year);
    final savingsDocs = await _dataSource.getSavingsByMonth(userId, month, year);

    final List<Movement> movements = [];

    for (var doc in historyDocs) {
      movements.add(_mapToMovement(doc, isSaving: false));
    }

    for (var doc in savingsDocs) {
      movements.add(_mapToMovement(doc, isSaving: true));
    }

    movements.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return movements;
  }

  @override
  Future<void> saveMovement(Movement movement) async {
    final String uid = Preferences.uId;

    if (movement.type == MovementType.saving) {
      await _dataSource.addSaving(
        documentId: movement.id, 
        userId: uid, 
        money: movement.amount,
        month: movement.month,
        year: movement.year,
        description: movement.name,
      );
    } else {
      await _dataSource.addHistory(
        documentId: movement.id, 
        userId: uid,
        name: movement.name,
        money: movement.amount,
        isIncome: movement.isIncome,
        currentDate: movement.date,
        currentHour: movement.hour,
        month: movement.month,
        year: movement.year,
        isRecurrent: movement.isRecurrent,
        category: movement.category,
        ticketId: movement.ticketId,
        imagePath: movement.imagePath,
        isTransferred: movement.isTransferred,
      );
    }
  }

  @override
  Future<void> deleteMovement(String id) async {
    try {
      await _dataSource.deleteHistory(id);
    } catch (_) {
      await _dataSource.deleteSaving(id);
    }
  }

  @override
  Future<double> getGlobalBalance(String userId) async {
    return await _dataSource.getTotalBalance();
  }

  @override
  Future<void> updateGlobalBalance(String userId, double amount) async {
    await _dataSource.updateTotalBalance(amount);
  }

  @override
  Future<Map<String, dynamic>> syncAllData(String userId, Function(double) onProgress) async {
    return await _dataSource.syncFullData(userId, onProgress);
  }

  Movement _mapToMovement(dynamic doc, {required bool isSaving}) {
    final Map<String, dynamic> data = doc.data;
    MovementType type = MovementType.expense;
    
    if (isSaving) {
      type = MovementType.saving;
    } else if (data['isIncome'] == true) {
      type = MovementType.income;
    }

    return Movement(
      id: doc.$id,
      name: isSaving ? (data['description'] ?? 'Ahorro') : (data['name'] ?? 'Sin nombre'),
      amount: (data['money'] as num).toDouble(),
      type: type,
      isIncome: data['isIncome'] ?? false,
      date: data['currentDate'] ?? '',
      hour: data['currentHour'] ?? '',
      month: data['month']?.toString() ?? '',
      year: int.tryParse(data['year']?.toString() ?? '0') ?? 0,
      createdAt: DateTime.parse(doc.$createdAt),
      isSpent: data['isSpent'] ?? false,
      isRecurrent: data['isRecurrent'] ?? false,
      category: data['category'] ?? (isSaving ? 'ahorro' : 'general'),
      ticketId: data['ticketId'],
      imagePath: data['imagePath'],
      isTransferred: data['isTransferred'] ?? false,
    );
  }
}
