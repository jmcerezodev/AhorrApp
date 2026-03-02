import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/domain/repositories/i_recurrent_expense_repository.dart';

class DeleteRecurrentExpenseUseCase {
  final IRecurrentExpenseRepository localRepository;
  final IRecurrentExpenseRepository remoteRepository;
  final LocalDbService localDbService;

  DeleteRecurrentExpenseUseCase({
    required this.localRepository,
    required this.remoteRepository,
    required this.localDbService,
  });

  Future<void> call(String id) async {
    // 1. Eliminación Local
    await localRepository.deleteRecurrentExpense(id);

    // 2. Sincronización Remota
    try {
      await remoteRepository.deleteRecurrentExpense(id);
    } catch (e) {
      // Cola de sincronización si falla internet
      await localDbService.addPendingSync(
        'delete',
        'recurrent_expenses',
        {},
        appwriteId: id,
      );
    }
  }
}
