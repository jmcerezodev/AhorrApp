import '../../repositories/tickets_repository.dart';

class ClearTicketsUseCase {
  final TicketsRepository repository;
  ClearTicketsUseCase(this.repository);
  Future<void> call(String userId) => repository.clearTicketItems(userId);
}
