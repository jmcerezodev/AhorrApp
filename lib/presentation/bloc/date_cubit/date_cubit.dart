import 'package:ahorrapp/core/date/date.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'date_cubit_state.dart';

class DateCubit extends Cubit<DateCubitState> {

  DateCubit() : super(const DateCubitState());
  
  // REINICIO MAESTRO: Vuelve al mes y año actual
  void resetCubit() {
    emit(const DateCubitState());
    currentMonth();
    currentYear();
  }

  void isOpen(bool value){
    emit(state.copyWith(
      isOpen: value,
    ));
  }

  void dateCurrent(){
      final String currentDate = Date().currentDate();
    emit(
      state.copyWith(
        currentDate: currentDate,
      )
    );
  }

  void currentYear(){
    final String currentYear = Date().year();
    emit(state.copyWith(
      year: int.parse(currentYear),
    ));
  }

  void yearIncrement(int value){
    emit(state.copyWith(
      year: state.year + value,
    ));
  }

  void yearDecrement(int value){
    emit(state.copyWith(
      year: state.year - value,
    ));
  }
  
  void currentMonth(){
    final String currentMonth = Date().monthNames();
    emit(state.copyWith(
      month: currentMonth,
    ));
  }

  void month(String value){
    emit(state.copyWith(
      month: value,
    ));
  }

  void isActive(bool value){
    emit(state.copyWith(
      isActive: value
    ));
  }
}
