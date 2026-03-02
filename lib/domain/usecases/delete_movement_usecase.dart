import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/presentation/bloc/total_money_cubit/total_money_cubit.dart';
import '../entities/movement.dart';
import '../repositories/i_movement_repository.dart';

class DeleteMovementUseCase {
  final IMovementRepository localRepository;
  final IMovementRepository remoteRepository;
  final LocalDbService localDbService;
  final TotalMoneyCubit totalMoneyCubit;

  DeleteMovementUseCase({
    required this.localRepository,
    required this.remoteRepository,
    required this.localDbService,
    required this.totalMoneyCubit,
  });

  Future<void> call(Movement movement) async {
    final String uid = Preferences.uId;

    // 1. ELIMINACIÓN LOCAL (Siempre lo primero)
    await localRepository.deleteMovement(movement.id);

    // 2. REVERTIR IMPACTO EN EL BALANCE (Solo si no es ahorro)
    if (movement.type != MovementType.saving) {
      double currentBalance = await localRepository.getGlobalBalance(uid);
      
      // Si eliminamos un ingreso, restamos. Si eliminamos un gasto, sumamos.
      if (movement.isIncome) {
        currentBalance -= movement.amount;
      } else {
        currentBalance += movement.amount;
      }
      
      await localRepository.updateGlobalBalance(uid, currentBalance);
      totalMoneyCubit.totalMoney(currentBalance);

      try {
        await remoteRepository.updateGlobalBalance(uid, currentBalance);
      } catch (_) {}
    }

    // 3. SINCRONIZACIÓN DE LA ELIMINACIÓN
    try {
      await remoteRepository.deleteMovement(movement.id);
    } catch (e) {
      // Cola de sincronización si falla internet
      await localDbService.addPendingSync(
        'delete',
        movement.type == MovementType.saving ? 'savings' : 'history',
        {}, // No necesitamos datos para borrar, solo el ID
        appwriteId: movement.id,
      );
    }
  }
}
