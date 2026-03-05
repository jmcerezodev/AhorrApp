part of 'history_cubit.dart';

enum HistoryStatus { initial, loading, success, failure }

class HistoryCubitState extends Equatable {
  final bool isValid;
  final HistoryStatus status;
  final List<Map<String, dynamic>> historyList;
  final String listOrder;
  final IncomeNameInput newName;
  final IncomeMoneyInput newMoney;
  final String currentName;
  final String currentMoney;
  final bool isChart;
  
  final bool showIncomes;
  final bool showExpenses;
  final bool showSavings;
  final bool isFilterOpen;
  final List<String> selectedCategories; // NUEVO: Categorías seleccionadas para filtrar

  final bool isSyncing;
  final double syncProgress;
  final String? errorMessage;

  const HistoryCubitState({
    this.isValid = false,
    this.status = HistoryStatus.initial,
    this.historyList = const [],
    this.listOrder = 'descending',
    this.newName = const IncomeNameInput.pure(),
    this.newMoney = const IncomeMoneyInput.pure(),
    this.currentName = '',
    this.currentMoney = '',
    this.isChart = false,
    this.showIncomes = true,
    this.showExpenses = true,
    this.showSavings = true,
    this.isFilterOpen = false,
    this.selectedCategories = const [], // Por defecto todas visibles
    this.isSyncing = false,
    this.syncProgress = 0.0,
    this.errorMessage,
  });

  HistoryCubitState copyWith({
    bool? isValid,
    HistoryStatus? status,
    List<Map<String, dynamic>>? historyList,
    String? listOrder,
    IncomeNameInput? newName,
    IncomeMoneyInput? newMoney,
    String? currentName,
    String? currentMoney,
    bool? isChart,
    bool? showIncomes,
    bool? showExpenses,
    bool? showSavings,
    bool? isFilterOpen,
    List<String>? selectedCategories,
    bool? isSyncing,
    double? syncProgress,
    String? errorMessage,
  }) =>
      HistoryCubitState(
        isValid: isValid ?? this.isValid,
        status: status ?? this.status,
        historyList: historyList ?? this.historyList,
        listOrder: listOrder ?? this.listOrder,
        newName: newName ?? this.newName,
        newMoney: newMoney ?? this.newMoney,
        currentName: currentName ?? this.currentName,
        currentMoney: currentMoney ?? this.currentMoney,
        isChart: isChart ?? this.isChart,
        showIncomes: showIncomes ?? this.showIncomes,
        showExpenses: showExpenses ?? this.showExpenses,
        showSavings: showSavings ?? this.showSavings,
        isFilterOpen: isFilterOpen ?? this.isFilterOpen,
        selectedCategories: selectedCategories ?? this.selectedCategories,
        isSyncing: isSyncing ?? this.isSyncing,
        syncProgress: syncProgress ?? this.syncProgress,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [
        isValid,
        status,
        historyList,
        listOrder,
        newName,
        newMoney,
        currentName,
        currentMoney,
        isChart,
        showIncomes,
        showExpenses,
        showSavings,
        isFilterOpen,
        selectedCategories,
        isSyncing,
        syncProgress,
        errorMessage,
      ];
}
