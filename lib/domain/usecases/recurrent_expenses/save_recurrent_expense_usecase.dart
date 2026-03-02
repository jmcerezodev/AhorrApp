import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:ahorrapp/domain/repositories/i_recurrent_expense_repository.dart';

class SaveRecurrentExpenseUseCase {
  final IRecurrentExpenseRepository localRepository;
  final IRecurrentExpenseRepository remoteRepository;
  final LocalDbService localDbService;

  SaveRecurrentExpenseUseCase({
    required this.localRepository,
    required this.remoteRepository,
    required this.localDbService,
  });

  Future<void> call(RecurrentExpense expense) async {
    // 1. Guardado Local
    await localRepository.saveRecurrentExpense(expense);

    // 2. Sincronización Remota
    try {
      await remoteRepository.saveRecurrentExpense(expense);
    } catch (e) {
      // Cola de sincronización si falla internet
      await localDbService.addPendingSync(
        'create', // Usamos create, el repo remoto manejará si es update internamente
        'recurrent_expenses',
        {
          'userId': expense.userId,
          'name': expense.name,
          'money': expense.amount,
          'day': expense.day,
          'category': expense.category,
          'isActive': expense.isActive,
          'lastApplied': expense.lastApplied,
        },
        appwriteId: expense.id,
      );
    }
  }
}
