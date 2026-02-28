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
  final TotalMoneyCubit totalMoneyCubit; // Añadimos referencia al Cubit de dinero

  HistoryCubit({required this.totalMoneyCubit}) : super(const HistoryCubitState()) {
    if (Preferences.uId.isNotEmpty) {
      loadHistory();
    }
  }

  Future<void> loadHistory() async {
    emit(state.copyWhith(formStatus: FormStatusHistory.validating));
    try {
      final documents = await _repository.getHistory(Preferences.uId);
      
      final List<Map<String, dynamic>> history = documents.map((doc) {
        return {
          'id': doc.$id,
          'name': doc.data['name'],
          'money': doc.data['money'],
          'isIncome': doc.data['isIncome'],
          'currentDate': doc.data['currentDate'],
          'currentHour': doc.data['currentHour'],
          'month': doc.data['month'],
          'year': doc.data['year'],
          'userId': doc.data['userId'],
        };
      }).toList();

      emit(state.copyWhith(
        historyList: history,
        formStatus: FormStatusHistory.valid
      ));

      // CALCULAMOS Y ACTUALIZAMOS EL TOTAL MONEY AUTOMÁTICAMENTE
      _updateGlobalBalance(history);

    } catch (e) {
      emit(state.copyWhith(formStatus: FormStatusHistory.invalid));
    }
  }

  void _updateGlobalBalance(List<Map<String, dynamic>> history) {
    double total = 0;
    for (var item in history) {
      final double money = (item['money'] as num).toDouble();
      if (item['isIncome'] == true) {
        total += money;
      } else {
        total -= money;
      }
    }
    // Actualizamos el otro Cubit instantáneamente
    totalMoneyCubit.totalMoney(total);
  }

  void onSubmit() async {
    if (!state.isValid) return;
    emit(state.copyWhith(formStatus: FormStatusHistory.validating));
    emit(state.copyWhith(formStatus: FormStatusHistory.valid));
  }

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

  void historyData(List<Map<String, dynamic>> value) {
    emit(state.copyWhith(historyList: value));
    _updateGlobalBalance(value);
  }

  void currentText(String value) {
    emit(state.copyWhith(currentName: value));
  }

  void currentMoney(String value) {
    emit(state.copyWhith(currentMoney: value));
  }

  void listOrder(String value) {
    emit(state.copyWhith(listOrder: value));
  }

  void isChart(bool value) {
    emit(state.copyWhith(isChart: value));
  }
}
