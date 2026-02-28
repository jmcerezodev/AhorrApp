import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FilterLists {

  int findMaxYear(List<Map<String, dynamic>> historyList) {
    final date = Date();
    if (historyList.isNotEmpty) {
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

  // --- CORRECCIÓN CRÍTICA: Ahorros independientes del Balance Total ---
  double calculateTotalMoney(BuildContext context, HistoryCubit historyCubit) {
    final historyList = historyCubit.state.historyList;
    
    double totalMoney = 0;

    for (var item in historyList) {
      final double money = (item['money'] as num).toDouble();
      
      // Solo sumamos ingresos reales
      if (item['type'] == 'income') {
        totalMoney += money;
      } 
      // Solo restamos gastos reales
      else if (item['type'] == 'expense') {
        totalMoney -= money;
      }
      // El caso type == 'saving' NO se suma ni se resta del balance global
    }
    
    context.read<TotalMoneyCubit>().totalMoney(totalMoney);
    return totalMoney;
  }

  List<double> calculateTotalIncomes(List<Map<String, dynamic>> historyList, int year) {
    List<double> totalIncomesList = [];
    List<String> months = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"];

    for (var month in months) {
      List<Map<String, dynamic>> monthsFilter = historyList.where((item) => item['month'] == month && item['year'] == year).toList();
      double totalIncome = 0;
      for (var map in monthsFilter) {
        if (map['type'] == 'income') {
          totalIncome += (map['money'] as num).toDouble();
        }
      }
      totalIncomesList.add(totalIncome);
    }
    return totalIncomesList;
  }

  List<double> calculateTotalExpenses(List<Map<String, dynamic>> historyList, int year) {
    List<double> totalExpensesList = [];
    List<String> months = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"];

    for (var month in months) {
      List<Map<String, dynamic>> monthsFilter = historyList.where((item) => item['month'] == month && item['year'] == year).toList();
      double totalExpenses = 0;
      for (var map in monthsFilter) {
        if (map['type'] == 'expense') {
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

    double totalIncome = 0;
    for (var map in filteredListDate) {
      if (map['type'] == 'income') {
        totalIncome += (map['money'] as num).toDouble();
      }
    }
    return totalIncome;
  }

  double totalExpense(BuildContext context, List<Map<String, dynamic>> historyList) {
    final dateCubit = context.watch<DateCubit>().state;
    List<Map<String, dynamic>> filteredListDate = historyList.where((date) {
      return date["year"] == dateCubit.year && date["month"] == dateCubit.month;
    }).toList();

    double totalExpense = 0;
    for (var map in filteredListDate) {
      if (map['type'] == 'expense') {
        totalExpense += (map['money'] as num).toDouble();
      }
    }
    return totalExpense;
  }
}
