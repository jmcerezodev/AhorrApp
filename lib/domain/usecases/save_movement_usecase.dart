import 'package:ahorrapp/data/local/local_db_service.dart';
import '../entities/movement.dart';
import '../repositories/i_movement_repository.dart';

class SaveMovementUseCase {
  final IMovementRepository localRepository;
  final IMovementRepository remoteRepository;
  final LocalDbService localDbService;

  SaveMovementUseCase({
    required this.localRepository,
    required this.remoteRepository,
    required this.localDbService,
  });

  Future<void> call(Movement movement) async {
    // 1. Guardamos en Isar (Local) inmediatamente para velocidad total
    await localRepository.saveMovement(movement);

    try {
      // 2. Intentamos guardar en Appwrite (Nube)
      await remoteRepository.saveMovement(movement);
    } catch (e) {
      // 3. Si falla (offline), lo guardamos en la cola de sincronización de Isar
      await localDbService.addPendingSync(
        'create',
        movement.type == MovementType.saving ? 'savings' : 'history',
        {
          'userId': movement.id, // Asumiendo que guardamos el userId en este campo
          'name': movement.name,
          'money': movement.amount,
          'isIncome': movement.isIncome,
          'date': movement.date,
          'hour': movement.hour,
          'month': movement.month,
          'year': movement.year,
        },
      );
    }
  }
}
