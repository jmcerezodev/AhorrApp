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
    if (movement.type != MovementType.saving) {
      double currentBalance = await localRepository.getGlobalBalance(uid);
      
      if (movement.isIncome) {
        currentBalance += movement.amount;
      } else {
        currentBalance -= movement.amount;
      }
      
      await localRepository.updateGlobalBalance(uid, currentBalance);
      totalMoneyCubit.totalMoney(currentBalance);

      try {
        await remoteRepository.updateGlobalBalance(uid, currentBalance);
      } catch (_) {}
    }

    // 3. SINCRONIZACIÓN DEL MOVIMIENTO
    try {
      await remoteRepository.saveMovement(movement);
    } catch (e) {
      // Cola de sincronización si falla internet
      final bool isSaving = movement.type == MovementType.saving;
      await localDbService.addPendingSync(
        'create',
        isSaving ? 'savings' : 'history',
        {
          'userId': uid,
          if (isSaving) 'description': movement.name else 'name': movement.name,
          'money': movement.amount,
          'isIncome': movement.isIncome,
          'date': movement.date,
          'hour': movement.hour,
          'month': movement.month,
          'year': movement.year,
          'isRecurrent': movement.isRecurrent,
          'category': movement.category,
          'ticketId': movement.ticketId,
          'imagePath': movement.imagePath,
          'remoteImageId': movement.remoteImageId, // AÑADIDO
          'isTransferred': movement.isTransferred,
        },
        appwriteId: movement.id, 
      );
    }
  }
}
