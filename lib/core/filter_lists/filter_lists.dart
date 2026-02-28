import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FilterLists {

  // * Filtro para encontrar el año mas bajo y el mas alto de la lista

  int findMaxYear(List<Map<String, dynamic>> historyList) {
    final date = Date();
    if (historyList.isNotEmpty) {
      // Appwrite nos devuelve el año como int, ya no necesitamos int.parse
      return historyList.map((item) => item['year'] as int).reduce((a, b) => a > b ? a : b);
    } else {
      return int.parse(date.year());
    }
  }

  int findMinYear(List<Map<String, dynamic>> historyList) {
    final date = Date();
    if (historyList.isNotEmpty) {
      return historyList.map((item) => item['year'] as int).reduce((a, b) => a < b ? a : b);
    } else {
      return int.parse(date.year());
    }
  }

  // * Filtrar y hacer los calculos para el dinero total

  double calculateTotalMoney(BuildContext context, HistoryCubit historyCubit) {
    List<Map<String, dynamic>> filteredListIncome = historyCubit.state.historyList.where((item) {
      return item["isIncome"] == true;
    }).toList();

    List<Map<String, dynamic>> filteredListExpense = historyCubit.state.historyList.where((item) {
      return item["isIncome"] == false;
    }).toList();

    double totalMoney = 0;

    for (var map in filteredListIncome) {
      // Appwrite nos devuelve money como double, ya no necesitamos double.parse
      totalMoney += (map['money'] as num).toDouble();
    }

    for (var map in filteredListExpense) {
      totalMoney -= (map['money'] as num).toDouble();
    }
    
    context.read<TotalMoneyCubit>().totalMoney(totalMoney);
    return totalMoney;
  }

  // * Filtrar listas para mostrar el total de ingresos y gastos en la Grafica por meses

  List<double> calculateTotalIncomes(List<Map<String, dynamic>> historyList, int year) {
    List<double> totalIncomesList = [];
    List<String> months = [
      "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", 
      "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
    ];

    for (var month in months) {
      // Comparamos el año como int
      List<Map<String, dynamic>> monthsFilter = historyList.where((item) => item['month'] == month && item['year'] == year).toList();
      double totalIncome = 0;

      for (var map in monthsFilter) {
        if (map['isIncome'] == true) {
          totalIncome += (map['money'] as num).toDouble();
        }
      }
      totalIncomesList.add(totalIncome);
    }
    return totalIncomesList;
  }

  List<double> calculateTotalExpenses(List<Map<String, dynamic>> historyList, int year) {
    List<double> totalExpensesList = [];
    List<String> months = [
      "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", 
      "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
    ];

    for (var month in months) {
      List<Map<String, dynamic>> monthsFilter = historyList.where((item) => item['month'] == month && item['year'] == year).toList();
      double totalExpenses = 0;

      for (var map in monthsFilter) {
        if (map['isIncome'] == false) {
          totalExpenses += (map['money'] as num).toDouble();
        }
      }
      totalExpensesList.add(totalExpenses);
    }
    return totalExpensesList;
  }

  double totalIncome(BuildContext context, List<Map<String, dynamic>> historyList) {
    final dateCubit = context.watch<DateCubit>().state;

    List<Map<String, dynamic>> filteredListDate = historyList.where((date) {
      return date["year"] == dateCubit.year && date["month"] == dateCubit.month;
    }).toList();

    List<Map<String, dynamic>> filteredListIncome = filteredListDate.where((item) {
      return item["isIncome"] == true;
    }).toList();

    double totalIncome = 0;
    for (var map in filteredListIncome) {
      totalIncome += (map['money'] as num).toDouble();
    }
    return totalIncome;
  }

  double totalExpense(BuildContext context, List<Map<String, dynamic>> historyList) {
    final dateCubit = context.watch<DateCubit>().state;

    List<Map<String, dynamic>> filteredListDate = historyList.where((date) {
      return date["year"] == dateCubit.year && date["month"] == dateCubit.month;
    }).toList();

    List<Map<String, dynamic>> filteredListExpense = filteredListDate.where((item) {
      return item["isIncome"] == false;
    }).toList();

    double totalExpense = 0;
    for (var map in filteredListExpense) {
      totalExpense += (map['money'] as num).toDouble();
    }
    return totalExpense;
  }
}
