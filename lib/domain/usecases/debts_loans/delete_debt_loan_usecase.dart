import 'package:ahorrapp/core/network/connectivity_service.dart';
import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/domain/repositories/debt_loan_repository.dart';

class DeleteDebtLoanUseCase {
  final DebtLoanRepository localRepository;
  final DebtLoanRepository remoteRepository;
  final LocalDbService localDbService;

  DeleteDebtLoanUseCase({
    required this.localRepository,
    required this.remoteRepository,
    required this.localDbService,
  });

  Future<void> call(String id) async {
    // 1. Borrar localmente siempre
    await localRepository.deleteDebtLoan(id);

    // 2. Intentar borrar en remoto si hay conexión
    final connectivity = getIt<ConnectivityService>();
    if (connectivity.currentStatus == NetworkStatus.online) {
      try {
        await remoteRepository.deleteDebtLoan(id);
      } catch (e) {
        // Si falla el remoto, añadir a la cola de sincronización pendiente
        await localDbService.addPendingSync('DELETE', 'debts_loans', {}, appwriteId: id);
      }
    } else {
      // Si no hay conexión, añadir a la cola
      await localDbService.addPendingSync('DELETE', 'debts_loans', {}, appwriteId: id);
    }
  }
}
