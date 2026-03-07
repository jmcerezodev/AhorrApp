import '../../repositories/tickets_repository.dart';

class DeleteTicketItemUseCase {
  final TicketsRepository repository;
  DeleteTicketItemUseCase(this.repository);
  Future<void> call(String id) => repository.deleteTicketItem(id);
}
