import '../../entities/ticket_item.dart';
import '../../repositories/tickets_repository.dart';

class GetTicketItemsUseCase {
  final TicketsRepository repository;
  GetTicketItemsUseCase(this.repository);
  Future<List<TicketItem>> call(String userId) => repository.getTicketItems(userId);
}
