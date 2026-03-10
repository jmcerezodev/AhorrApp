import 'package:ahorrapp/domain/repositories/debt_loan_repository.dart';

class DeleteDebtLoanUseCase {
  final DebtLoanRepository repository;
  DeleteDebtLoanUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteDebtLoan(id);
  }
}
