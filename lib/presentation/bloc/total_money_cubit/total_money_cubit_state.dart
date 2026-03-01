part of 'total_money_cubit.dart';

class TotalMoneyCubitState extends Equatable {
  final double totalMoney;

  const TotalMoneyCubitState({
    this.totalMoney = 0,
  });

  TotalMoneyCubitState copyWith({
    double? totalMoney,
  }) =>
      TotalMoneyCubitState(
        totalMoney: totalMoney ?? this.totalMoney,
      );

  @override
  List<Object?> get props => [totalMoney];
}
