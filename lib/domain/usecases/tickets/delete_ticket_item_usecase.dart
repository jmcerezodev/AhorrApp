import '../../repositories/tickets_repository.dart';
import '../../repositories/i_movement_repository.dart';

class DeleteTicketItemUseCase {
  final TicketsRepository ticketsRepository;
  final IMovementRepository movementRepository;

  DeleteTicketItemUseCase({
    required this.ticketsRepository,
    required this.movementRepository,
  });

  Future<void> call(String id) async {
    // 1. Desvincular de cualquier movimiento (gasto)
    await movementRepository.detachTicketFromMovements(id);
    
    // 2. Eliminar el ticket físicamente y de la base de datos
    await ticketsRepository.deleteTicketItem(id);
  }
}
