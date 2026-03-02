import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'total_money_cubit_state.dart';

class TotalMoneyCubit extends Cubit<TotalMoneyCubitState> {
  TotalMoneyCubit() : super(TotalMoneyCubitState(
    isSavingsIncluded: Preferences.isSavingsIncludedInBalance
  ));

  void resetCubit() {
    emit(TotalMoneyCubitState(
      isSavingsIncluded: Preferences.isSavingsIncludedInBalance
    ));
  }

  void addition(double value){
    emit(state.copyWith(totalMoney: state.totalMoney + value));
  }

  void subtraction(double value){
    emit(state.copyWith(totalMoney: state.totalMoney - value));
  }

  void totalMoney(double value){
    emit(state.copyWith(totalMoney: value));
  }

  void toggleSavingsInclusion() {
    final newValue = !state.isSavingsIncluded;
    Preferences.isSavingsIncludedInBalance = newValue;
    emit(state.copyWith(isSavingsIncluded: newValue));
  }
}
