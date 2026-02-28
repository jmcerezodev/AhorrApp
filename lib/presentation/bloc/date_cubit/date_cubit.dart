import 'package:ahorrapp/core/date/date.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'date_cubit_state.dart';

class DateCubit extends Cubit<DateCubitState> {

  DateCubit() : super(const DateCubitState());
  

  void isOpen(bool value){
    emit(state.copywith(
      isOpen: !state.isOpen,
    ));
  }

  // * Fecha completa Actual

  void dateCurrent(){
      final String currentDate = Date().currentDate();
    emit(
      state.copywith(
        currentDate: currentDate,
      )
    );
  }

  // * Año
  void currentYear(){
    final String currentYear = Date().year();
    emit(state.copywith(
      year: int.parse(currentYear),
    ));
  }

  void yearIncrement(int value){
    // Aseguramos que sume el valor recibido (normalmente 1)
    emit(state.copywith(
      year: state.year + value,
    ));
  }

  void yearDecrement(int value){
    // Aseguramos que reste el valor recibido (normalmente 1)
    emit(state.copywith(
      year: state.year - value,
    ));
  }

  // * Meses
  
  void currentMonth(){
    final String currentMonth = Date().monthNames();
    emit(state.copywith(
      month: currentMonth,
    ));
  }

  void month(String value){
    emit(state.copywith(
      month: value,
    ));
  }

  void isActive(bool value){
    emit(state.copywith(
      isActive: value // Corregido: antes asignaba state.isActive a sí mismo
    ));
  }

}
