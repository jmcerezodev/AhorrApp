part of 'recurrent_expenses_cubit.dart';

enum RecurrentExpensesStatus { initial, loading, success, failure }

class RecurrentExpensesState extends Equatable {
  final List<RecurrentExpense> expenses;
  final RecurrentExpensesStatus status;
  final String? errorMessage;
  final bool showProrated; // Preferencia de visualización

  const RecurrentExpensesState({
    this.expenses = const [],
    this.status = RecurrentExpensesStatus.initial,
    this.errorMessage,
    this.showProrated = false, // Valor por defecto: Mensual
  });

  // Lógica centralizada para determinar si un gasto debe sumarse a los totales
  bool _shouldInclude(RecurrentExpense e) {
    if (!e.isActive) return false;
    // Si es automático (tiene día fijo), se suma siempre.
    // Si es manual, depende de la elección del usuario (includeInSummary).
    return (e.day != null) || e.includeInSummary;
  }

  // Cálculo de la carga mensual normalizada (prorrateo)
  double get totalMonthlyNormalized {
    double total = 0;
    for (var expense in expenses) {
      if (_shouldInclude(expense)) {
        switch (expense.frequency) {
          case RecurrentFrequency.monthly:
            total += expense.amount;
            break;
          case RecurrentFrequency.quarterly:
            total += expense.amount / 3;
            break;
          case RecurrentFrequency.semiAnnually:
            total += expense.amount / 6;
            break;
          case RecurrentFrequency.annually:
            total += expense.amount / 12;
            break;
        }
      }
    }
    return total;
  }

  // Cálculo de gastos estrictamente mensuales
  double get totalStrictlyMonthly {
    return expenses
        .where((e) => _shouldInclude(e) && e.frequency == RecurrentFrequency.monthly)
        .fold(0, (sum, e) => sum + e.amount);
  }

  RecurrentExpensesState copyWith({
    List<RecurrentExpense>? expenses,
    RecurrentExpensesStatus? status,
    String? errorMessage,
    bool? showProrated,
  }) {
    return RecurrentExpensesState(
      expenses: expenses ?? this.expenses,
      status: status ?? this.status,
      errorMessage: errorMessage,
      showProrated: showProrated ?? this.showProrated,
    );
  }

  @override
  List<Object?> get props => [expenses, status, errorMessage, showProrated];
}
