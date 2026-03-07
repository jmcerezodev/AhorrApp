import '../../entities/ticket_item.dart';
import '../../repositories/tickets_repository.dart';

class ReorderTicketItemsUseCase {
  final TicketsRepository repository;
  ReorderTicketItemsUseCase(this.repository);
  Future<void> call(List<TicketItem> items) => repository.reorderTicketItems(items);
}
