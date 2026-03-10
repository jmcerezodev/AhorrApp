import 'package:ahorrapp/core/network/connectivity_service.dart';
import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/domain/repositories/debt_loan_repository.dart';

class UpdateDebtLoanUseCase {
  final DebtLoanRepository localRepository;
  final DebtLoanRepository remoteRepository;
  final LocalDbService localDbService;

  UpdateDebtLoanUseCase({
    required this.localRepository,
    required this.remoteRepository,
    required this.localDbService,
  });

  Future<void> call(DebtLoan debtLoan) async {
    // 1. Actualizar localmente siempre
    await localRepository.updateDebtLoan(debtLoan);

    // 2. Intentar actualizar en remoto si hay conexión
    final connectivity = getIt<ConnectivityService>();
    if (connectivity.currentStatus == NetworkStatus.online) {
      try {
        await remoteRepository.updateDebtLoan(debtLoan);
      } catch (e) {
        // Si falla el remoto, añadir a la cola de sincronización pendiente
        await localDbService.addPendingSync(
          'UPDATE', 
          'debts_loans', 
          _debtLoanToMap(debtLoan),
          appwriteId: debtLoan.id,
        );
      }
    } else {
      // Si no hay conexión, añadir a la cola
      await localDbService.addPendingSync(
        'UPDATE', 
        'debts_loans', 
        _debtLoanToMap(debtLoan),
        appwriteId: debtLoan.id,
      );
    }
  }

  Map<String, dynamic> _debtLoanToMap(DebtLoan debtLoan) {
    return {
      'userId': debtLoan.userId,
      'name': debtLoan.name,
      'person': debtLoan.person,
      'totalAmount': debtLoan.totalAmount,
      'paidAmount': debtLoan.paidAmount,
      'date': debtLoan.date?.toIso8601String(),
      'dueDate': debtLoan.dueDate?.toIso8601String(),
      'type': debtLoan.type == DebtLoanType.debt ? 'debt' : 'loan',
      'category': debtLoan.category,
      'isCompleted': debtLoan.isCompleted,
      'isInstallment': debtLoan.isInstallment,
      'totalInstallments': debtLoan.totalInstallments,
      'installmentAmount': debtLoan.installmentAmount,
      'recurrentExpenseId': debtLoan.recurrentExpenseId,
    };
  }
}
