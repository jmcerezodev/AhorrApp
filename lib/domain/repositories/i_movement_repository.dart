import '../entities/movement.dart';

abstract class IMovementRepository {
  Future<List<Movement>> getMovementsByMonth(String userId, String month, int year);
  Future<void> saveMovement(Movement movement);
  Future<void> deleteMovement(String id);
  Future<double> getGlobalBalance(String userId);
  Future<void> updateGlobalBalance(String userId, double amount);
  Future<Map<String, dynamic>> syncAllData(String userId, Function(double) onProgress);
  Future<void> detachTicketFromMovements(String ticketId);
}
