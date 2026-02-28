import 'package:ahorrapp/core/inputs/inputs.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

part 'history_cubit_state.dart';

class HistoryCubit extends Cubit<HistoryCubitState> {
  final AppwriteRepository _repository = AppwriteRepository();
  final TotalMoneyCubit totalMoneyCubit;

  HistoryCubit({required this.totalMoneyCubit}) : super(const HistoryCubitState()) {
    if (Preferences.uId.isNotEmpty) {
      loadHistory();
    }
  }

  Future<void> loadHistory() async {
    emit(state.copyWhith(formStatus: FormStatusHistory.validating));
    try {
      final historyDocs = await _repository.getHistory(Preferences.uId);
      final savingsDocs = await _repository.getSavings(Preferences.uId);
      
      final List<Map<String, dynamic>> history = historyDocs.map((doc) {
        return {
          'id': doc.$id,
          'name': doc.data['name'] ?? 'Sin nombre',
          'money': (doc.data['money'] as num).toDouble(),
          'isIncome': doc.data['isIncome'] ?? false,
          'type': (doc.data['isIncome'] == true) ? 'income' : 'expense',
          'currentDate': doc.data['currentDate'] ?? '',
          'currentHour': doc.data['currentHour'] ?? '',
          'month': doc.data['month']?.toString() ?? '',
          'year': int.tryParse(doc.data['year']?.toString() ?? '0') ?? 0,
          'userId': doc.data['userId'],
          'createdAt': doc.$createdAt,
        };
      }).toList();

      final List<Map<String, dynamic>> savings = savingsDocs.map((doc) {
        final DateTime date = DateTime.parse(doc.$createdAt);
        return {
          'id': doc.$id,
          'name': doc.data['description'] ?? 'Ahorro',
          'money': (doc.data['money'] as num).toDouble(),
          'isIncome': false, 
          'type': 'saving',
          'currentDate': "${date.day}/${date.month}/${date.year}",
          'currentHour': "${date.hour}:${date.minute}",
          'month': _getMonthName(date.month),
          'year': date.year,
          'userId': doc.data['userId'],
          'createdAt': doc.$createdAt,
        };
      }).toList();

      final List<Map<String, dynamic>> combinedList = [...history, ...savings];
      combinedList.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));

      emit(state.copyWhith(
        historyList: combinedList,
        formStatus: FormStatusHistory.valid
      ));

      _updateGlobalBalance(combinedList);

    } catch (e) {
      emit(state.copyWhith(formStatus: FormStatusHistory.invalid));
    }
  }

  String _getMonthName(int month) {
    const months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
    return months[month - 1];
  }

  // MÉTODO BLINDADO: Los ahorros NUNCA afectan al balance total
  void _updateGlobalBalance(List<Map<String, dynamic>> list) {
    double total = 0;
    for (var item in list) {
      final double money = (item['money'] as num).toDouble();
      
      // Solo operamos si NO es un ahorro
      if (item['type'] == 'income') {
        total += money;
      } else if (item['type'] == 'expense') {
        total -= money;
      }
      // El caso item['type'] == 'saving' se ignora explícitamente aquí
    }
    totalMoneyCubit.totalMoney(total);
  }

  void toggleIncomes(bool value) => emit(state.copyWhith(showIncomes: value));
  void toggleExpenses(bool value) => emit(state.copyWhith(showExpenses: value));
  void toggleSavings(bool value) => emit(state.copyWhith(showSavings: value));
  void toggleFilterPanel() => emit(state.copyWhith(isFilterOpen: !state.isFilterOpen));

  void resetCubit() {
    emit(state.copyWhith(
      newName: const IncomeNameInput.pure(),
      newMoney: const IncomeMoneyInput.pure()
    ));
  }

  void newNameChanged(String value) {
    final newName = IncomeNameInput.dirty(value: value);
    emit(state.copyWhith(
      newName: newName,
      isValid: Formz.validate([newName, state.newMoney]),
    ));
  }

  void newMoneyChanged(String value) {
    final newMoney = IncomeMoneyInput.dirty(value: value);
    emit(state.copyWhith(
      newMoney: newMoney,
      isValid: Formz.validate([newMoney, state.newName]),
    ));
  }

  void listOrder(String value) {
    emit(state.copyWhith(listOrder: value));
  }

  void isChart(bool value) {
    emit(state.copyWhith(isChart: value));
  }
}
