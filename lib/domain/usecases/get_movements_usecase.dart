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
    // 1. Intentamos leer de local (Estrategia Offline-First)
    final localMovements = await localRepository.getMovementsByMonth(userId, month, year);
    
    if (localMovements.isNotEmpty) {
      return localMovements;
    }

    // 2. Si no hay nada local, podríamos intentar remoto (o confiar en la sync inicial)
    // Para escalabilidad, devolvemos lo local ya que la sync maestra se encarga de llenar Isar.
    return localMovements;
  }
}
