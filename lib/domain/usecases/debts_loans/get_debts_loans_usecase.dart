import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/domain/repositories/debt_loan_repository.dart';

class GetDebtsLoansUseCase {
  final DebtLoanRepository repository;
  GetDebtsLoansUseCase(this.repository);

  Future<List<DebtLoan>> call(String userId) {
    return repository.getDebtsLoans(userId);
  }
}
