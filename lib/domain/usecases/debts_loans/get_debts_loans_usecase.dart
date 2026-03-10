import 'package:ahorrapp/core/network/connectivity_service.dart';
import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/domain/repositories/debt_loan_repository.dart';

class GetDebtsLoansUseCase {
  final DebtLoanRepository localRepository;
  final DebtLoanRepository remoteRepository;

  GetDebtsLoansUseCase({
    required this.localRepository,
    required this.remoteRepository,
  });

  Future<List<DebtLoan>> call(String userId) async {
    final connectivity = getIt<ConnectivityService>();
    
    if (connectivity.currentStatus == NetworkStatus.online) {
      try {
        final remoteItems = await remoteRepository.getDebtsLoans(userId);
        // Sincronización básica: en una implementación real actualizaríamos Isar aquí
        return remoteItems;
      } catch (_) {
        return localRepository.getDebtsLoans(userId);
      }
    }
    
    return localRepository.getDebtsLoans(userId);
  }
}
