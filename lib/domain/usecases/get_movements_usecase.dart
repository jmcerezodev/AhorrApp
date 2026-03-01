import '../entities/movement.dart';
import '../repositories/i_movement_repository.dart';

class GetMovementsUseCase {
  final IMovementRepository localRepository;
  final IMovementRepository remoteRepository;

  GetMovementsUseCase({
    required this.localRepository,
    required this.remoteRepository,
  });

  Future<List<Movement>> call(String userId, String month, int year) async {
    // La UI siempre debe leer de LOCAL (Isar) para ser instantánea.
    // La sincronización con la nube (Appwrite) ocurre en segundo plano o al forzar resync.
    return await localRepository.getMovementsByMonth(userId, month, year);
  }
}
