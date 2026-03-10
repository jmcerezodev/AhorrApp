import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/domain/repositories/debt_loan_repository.dart';

class AddDebtLoanUseCase {
  final DebtLoanRepository repository;
  AddDebtLoanUseCase(this.repository);

  Future<void> call(DebtLoan debtLoan) {
    return repository.addDebtLoan(debtLoan);
  }
}
