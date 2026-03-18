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
  final bool showDebts; // NUEVO: Filtro para deudas y préstamos
  final List<String> selectedCategories;
  final String searchQuery;

  const RecurrentExpensesState({
    this.expenses = const [],
    this.status = RecurrentExpensesStatus.initial,
    this.errorMessage,
    this.showProrated = false,
    this.isFilterOpen = false,
    this.showAutomatic = true,
    this.showManual = true,
    this.showDebts = true, // Por defecto visible
    this.selectedCategories = const [],
    this.searchQuery = '',
  });

  bool _shouldInclude(RecurrentExpense e) {
    if (!e.isActive) return false;
    return (e.day != null) || e.includeInSummary;
  }

  // --- CÁLCULOS PARA GASTOS ---
  double get totalExpenseProrated {
    double total = 0;
    for (var e in expenses.where((e) => !e.isIncome && _shouldInclude(e))) {
      total += e.amount / _getFrequencyFactor(e.frequency);
    }
    return total;
  }

  double get totalExpenseStrict {
    return expenses
        .where((e) => !e.isIncome && _shouldInclude(e) && e.frequency == RecurrentFrequency.monthly)
        .fold(0, (sum, e) => sum + e.amount);
  }

  // --- CÁLCULOS PARA INGRESOS ---
  double get totalIncomeProrated {
    double total = 0;
    for (var e in expenses.where((e) => e.isIncome && _shouldInclude(e))) {
      total += e.amount / _getFrequencyFactor(e.frequency);
    }
    return total;
  }

  double get totalIncomeStrict {
    return expenses
        .where((e) => e.isIncome && _shouldInclude(e) && e.frequency == RecurrentFrequency.monthly)
        .fold(0, (sum, e) => sum + e.amount);
  }

  double _getFrequencyFactor(RecurrentFrequency freq) {
    switch (freq) {
      case RecurrentFrequency.monthly: return 1;
      case RecurrentFrequency.quarterly: return 3;
      case RecurrentFrequency.semiAnnually: return 6;
      case RecurrentFrequency.annually: return 12;
    }
  }

  RecurrentExpensesState copyWith({
    List<RecurrentExpense>? expenses,
    RecurrentExpensesStatus? status,
    String? errorMessage,
    bool? showProrated,
    bool? isFilterOpen,
    bool? showAutomatic,
    bool? showManual,
    bool? showDebts,
    List<String>? selectedCategories,
    String? searchQuery,
  }) {
    return RecurrentExpensesState(
      expenses: expenses ?? this.expenses,
      status: status ?? this.status,
      errorMessage: errorMessage,
      showProrated: showProrated ?? this.showProrated,
      isFilterOpen: isFilterOpen ?? this.isFilterOpen,
      showAutomatic: showAutomatic ?? this.showAutomatic,
      showManual: showManual ?? this.showManual,
      showDebts: showDebts ?? this.showDebts,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      searchQuery: searchQuery ?? this.searchQuery,
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
    showDebts,
    selectedCategories,
    searchQuery,
  ];
}
