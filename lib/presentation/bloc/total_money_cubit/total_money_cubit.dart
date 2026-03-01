import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'total_money_cubit_state.dart';

class TotalMoneyCubit extends Cubit<TotalMoneyCubitState> {
  TotalMoneyCubit() : super(const TotalMoneyCubitState());

  // REINICIO MAESTRO: Vuelve el balance a cero
  void resetCubit() {
    emit(const TotalMoneyCubitState());
  }

   void addition(double value){
    emit(
      state.copyWith(
        totalMoney: state.totalMoney + value
      )
    );
   }

   void subtraction(double value){
    emit(
      state.copyWith(
        totalMoney: state.totalMoney - value
      )
    );
   }

   void totalMoney(double value){
    emit(state.copyWith(
      totalMoney: value
    ));
   }
}
