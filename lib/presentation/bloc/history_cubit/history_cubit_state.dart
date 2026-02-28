part of 'history_cubit.dart';

enum FormStatusHistory {invalid, valid, validating}

class HistoryCubitState extends Equatable{

  final bool isValid;
  final FormStatusHistory formStatus;
  final List<Map<String, dynamic>> historyList;
  final String listOrder;
  final IncomeNameInput newName;
  final IncomeMoneyInput newMoney;
  final String currentName;
  final String currentMoney;
  final bool isChart;
  
  // Filtros activos
  final bool showIncomes;
  final bool showExpenses;
  final bool showSavings;
  final bool isFilterOpen; // NUEVO: Controlar si el panel de filtros está abierto

  const HistoryCubitState({
    this.isValid = false,
    this.formStatus = FormStatusHistory.invalid,
    this.historyList = const [],
    this.listOrder = 'descending', // CAMBIADO: 'descending' por defecto para ver lo último arriba
    this.newName = const IncomeNameInput.pure(),
    this.newMoney = const IncomeMoneyInput.pure(),
    this.currentName = '',
    this.currentMoney = '',
    this.isChart = false,
    this.showIncomes = true,
    this.showExpenses = true,
    this.showSavings = true,
    this.isFilterOpen = false,
  });
  

  HistoryCubitState copyWhith ({
    bool? isValid,
    FormStatusHistory? formStatus,
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
  }) => HistoryCubitState(
    isValid: isValid ?? this.isValid,
    formStatus: formStatus ?? this.formStatus,
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
  );
  
  @override
  List<Object?> get props => [
    isValid, 
    formStatus, 
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
    isFilterOpen
  ];
}