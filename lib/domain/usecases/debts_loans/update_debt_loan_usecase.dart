import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/domain/repositories/debt_loan_repository.dart';

class UpdateDebtLoanUseCase {
  final DebtLoanRepository repository;
  UpdateDebtLoanUseCase(this.repository);

  Future<void> call(DebtLoan debtLoan) {
    return repository.updateDebtLoan(debtLoan);
  }
}
