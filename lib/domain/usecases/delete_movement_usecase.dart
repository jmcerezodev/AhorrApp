import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/domain/repositories/tickets_repository.dart';
import 'package:ahorrapp/presentation/bloc/total_money_cubit/total_money_cubit.dart';
import '../entities/movement.dart';
import '../repositories/i_movement_repository.dart';

class DeleteMovementUseCase {
  final IMovementRepository localRepository;
  final IMovementRepository remoteRepository;
  final LocalDbService localDbService;
  final TotalMoneyCubit totalMoneyCubit;
  final TicketsRepository ticketsRepository; // Añadido para gestionar tickets asociados

  DeleteMovementUseCase({
    required this.localRepository,
    required this.remoteRepository,
    required this.localDbService,
    required this.totalMoneyCubit,
    required this.ticketsRepository,
  });

  Future<void> call(Movement movement) async {
    final String uid = Preferences.uId;

    // 1. ELIMINACIÓN LOCAL
    await localRepository.deleteMovement(movement.id);

    // 2. REVERTIR ESTADO DE TICKET (Si estaba asociado)
    if (movement.ticketId != null) {
      await ticketsRepository.unmarkAsTransferred(movement.ticketId!);
    }

    // 3. REVERTIR IMPACTO EN EL BALANCE
    if (movement.type != MovementType.saving) {
      double currentBalance = await localRepository.getGlobalBalance(uid);
      
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

    // 4. SINCRONIZACIÓN DE LA ELIMINACIÓN
    try {
      await remoteRepository.deleteMovement(movement.id);
    } catch (e) {
      await localDbService.addPendingSync(
        'delete',
        movement.type == MovementType.saving ? 'savings' : 'history',
        {},
        appwriteId: movement.id,
      );
    }
  }
}
