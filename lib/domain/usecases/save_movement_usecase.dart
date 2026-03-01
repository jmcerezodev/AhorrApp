import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/presentation/bloc/total_money_cubit/total_money_cubit.dart';
import '../entities/movement.dart';
import '../repositories/i_movement_repository.dart';

class SaveMovementUseCase {
  final IMovementRepository localRepository;
  final IMovementRepository remoteRepository;
  final LocalDbService localDbService;
  final TotalMoneyCubit totalMoneyCubit;

  SaveMovementUseCase({
    required this.localRepository,
    required this.remoteRepository,
    required this.localDbService,
    required this.totalMoneyCubit,
  });

  Future<void> call(Movement movement) async {
    final String uid = Preferences.uId;

    // 1. GUARDADO LOCAL (Siempre lo primero)
    await localRepository.saveMovement(movement);

    // 2. LÓGICA DE BALANCE INDEPENDIENTE
    // Solo Ingresos y Gastos afectan al balance de la cartera.
    if (movement.type != MovementType.saving) {
      double currentBalance = await localRepository.getGlobalBalance(uid);
      
      if (movement.isIncome) {
        currentBalance += movement.amount;
      } else {
        currentBalance -= movement.amount;
      }
      
      // Actualizamos el saldo de la CARTERA
      await localRepository.updateGlobalBalance(uid, currentBalance);
      totalMoneyCubit.totalMoney(currentBalance);

      // Intentamos sincronizar el saldo en la nube
      try {
        await remoteRepository.updateGlobalBalance(uid, currentBalance);
      } catch (_) {}
    }

    // 3. SINCRONIZACIÓN DEL MOVIMIENTO
    try {
      await remoteRepository.saveMovement(movement);
    } catch (e) {
      // Cola de sincronización si falla internet
      await localDbService.addPendingSync(
        'create',
        movement.type == MovementType.saving ? 'savings' : 'history',
        {
          'userId': uid,
          'name': movement.name,
          'money': movement.amount,
          'isIncome': movement.isIncome,
          'date': movement.date,
          'hour': movement.hour,
          'month': movement.month,
          'year': movement.year,
        },
        appwriteId: movement.id, 
      );
    }
  }
}
