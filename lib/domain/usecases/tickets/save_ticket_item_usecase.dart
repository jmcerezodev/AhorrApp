import '../../entities/ticket_item.dart';
import '../../repositories/tickets_repository.dart';

class SaveTicketItemUseCase {
  final TicketsRepository repository;
  SaveTicketItemUseCase(this.repository);
  Future<void> call(TicketItem item) => repository.saveTicketItem(item);
}
