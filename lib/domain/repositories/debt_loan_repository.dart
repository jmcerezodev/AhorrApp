import 'package:ahorrapp/domain/entities/debt_loan.dart';

abstract class DebtLoanRepository {
  Future<List<DebtLoan>> getDebtsLoans(String userId);
  Future<void> addDebtLoan(DebtLoan debtLoan);
  Future<void> updateDebtLoan(DebtLoan debtLoan);
  Future<void> deleteDebtLoan(String id);
}
