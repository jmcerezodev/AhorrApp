part of 'recurrent_expenses_cubit.dart';

enum RecurrentExpensesStatus { initial, loading, success, failure }

class RecurrentExpensesState extends Equatable {
  final List<RecurrentExpense> expenses;
  final RecurrentExpensesStatus status;
  final String? errorMessage;
  final bool showProrated; 
  final bool isFilterOpen;
  final bool showAutomatic;
  final bool showManual;
  final List<String> selectedCategories; // NUEVO: Categorías seleccionadas para filtrar

  const RecurrentExpensesState({
    this.expenses = const [],
    this.status = RecurrentExpensesStatus.initial,
    this.errorMessage,
    this.showProrated = false,
    this.isFilterOpen = false,
    this.showAutomatic = true,
    this.showManual = true,
    this.selectedCategories = const [], // Por defecto vacío (todas visibles)
  });

  // Lógica centralizada para determinar si un gasto debe sumarse a los totales
  bool _shouldInclude(RecurrentExpense e) {
    if (!e.isActive) return false;
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
    bool? isFilterOpen,
    bool? showAutomatic,
    bool? showManual,
    List<String>? selectedCategories,
  }) {
    return RecurrentExpensesState(
      expenses: expenses ?? this.expenses,
      status: status ?? this.status,
      errorMessage: errorMessage,
      showProrated: showProrated ?? this.showProrated,
      isFilterOpen: isFilterOpen ?? this.isFilterOpen,
      showAutomatic: showAutomatic ?? this.showAutomatic,
      showManual: showManual ?? this.showManual,
      selectedCategories: selectedCategories ?? this.selectedCategories,
    );
  }

  @override
  List<Object?> get props => [
    expenses, 
    status, 
    errorMessage, 
    showProrated, 
    isFilterOpen, 
    showAutomatic, 
    showManual,
    selectedCategories,
  ];
}
