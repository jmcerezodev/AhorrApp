import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/presentation/bloc/total_money_cubit/total_money_cubit.dart';
import '../entities/movement.dart';
import '../repositories/i_movement_repository.dart';

class UpdateMovementUseCase {
  final IMovementRepository localRepository;
  final TotalMoneyCubit totalMoneyCubit;
  final LocalDbService localDbService;
  final AppwriteRepository remoteDataSource; // Usamos el datasource para el método específico

  UpdateMovementUseCase({
    required this.localRepository,
    required this.totalMoneyCubit,
    required this.localDbService,
    required this.remoteDataSource,
  });

  Future<void> call(Movement movement, double oldAmount) async {
    final String uid = Preferences.uId;

    // 1. ACTUALIZACIÓN LOCAL (Siempre lo primero)
    await localRepository.saveMovement(movement);

    // 2. RECALCULAR IMPACTO EN EL BALANCE (Solo si no es ahorro)
    if (movement.type != MovementType.saving) {
      double currentBalance = await localRepository.getGlobalBalance(uid);
      
      final double diff = (movement.amount - oldAmount) * (movement.isIncome ? 1 : -1);
      currentBalance += diff;
      
      await localRepository.updateGlobalBalance(uid, currentBalance);
      totalMoneyCubit.totalMoney(currentBalance);

      try {
        await remoteDataSource.updateTotalBalance(currentBalance);
      } catch (_) {}
    }

    // 3. SINCRONIZACIÓN DE LA ACTUALIZACIÓN
    try {
      final updateData = {'name': movement.name, 'money': movement.amount};
      
      if (movement.type == MovementType.saving) {
        await remoteDataSource.updateSaving(documentId: movement.id, data: updateData);
      } else {
        await remoteDataSource.updateHistory(documentId: movement.id, data: updateData);
      }
    } catch (e) {
      // Cola de sincronización si falla internet
      await localDbService.addPendingSync(
        'update',
        movement.type == MovementType.saving ? 'savings' : 'history',
        {'name': movement.name, 'money': movement.amount},
        appwriteId: movement.id,
      );
    }
  }
}
