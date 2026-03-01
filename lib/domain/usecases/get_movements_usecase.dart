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
    // 1. Intentamos leer de local (Velocidad instantánea)
    final localMovements = await localRepository.getMovementsByMonth(userId, month, year);
    
    if (localMovements.isNotEmpty) {
      return localMovements;
    }

    // 2. Si local está vacío, intentamos cargar de la nube (Appwrite)
    try {
      final remoteMovements = await remoteRepository.getMovementsByMonth(userId, month, year);
      return remoteMovements;
    } catch (e) {
      // 3. Si falla la red, devolvemos la lista local (que sabemos que está vacía)
      return localMovements;
    }
  }
}
