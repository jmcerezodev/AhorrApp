part of 'debts_loans_cubit.dart';

class DebtsLoansState extends Equatable {
  final List<DebtLoan> debtsLoans;
  final bool isLoading;
  final String? errorMessage;

  const DebtsLoansState({
    this.debtsLoans = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  double get totalDebts => debtsLoans
      .where((e) => e.type == DebtLoanType.debt && !e.isCompleted)
      .fold(0, (sum, item) => sum + item.remainingAmount);

  double get totalLoans => debtsLoans
      .where((e) => e.type == DebtLoanType.loan && !e.isCompleted)
      .fold(0, (sum, item) => sum + item.remainingAmount);

  DebtsLoansState copyWith({
    List<DebtLoan>? debtsLoans,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DebtsLoansState(
      debtsLoans: debtsLoans ?? this.debtsLoans,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [debtsLoans, isLoading, errorMessage];
}
