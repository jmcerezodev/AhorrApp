part of 'total_money_cubit.dart';

class TotalMoneyCubitState extends Equatable {
  final double totalMoney;
  final bool isSavingsIncluded;

  const TotalMoneyCubitState({
    this.totalMoney = 0.0,
    this.isSavingsIncluded = true,
  });

  TotalMoneyCubitState copyWith({
    double? totalMoney,
    bool? isSavingsIncluded,
  }) => TotalMoneyCubitState(
    totalMoney: totalMoney ?? this.totalMoney,
    isSavingsIncluded: isSavingsIncluded ?? this.isSavingsIncluded,
  );

  @override
  List<Object> get props => [totalMoney, isSavingsIncluded];
}
