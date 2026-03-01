part of 'date_cubit.dart';

class DateCubitState {
  final bool isOpen;
  final String currentDate;
  final int year;
  final String month;
  final bool isActive;

  const DateCubitState({
    this.isOpen = false,
    this.currentDate = '',
    this.year = 0,
    this.month = '',
    this.isActive = false,
  });

  // CORREGIDO: de copywith a copyWith
  DateCubitState copyWith({
    bool? isOpen,
    String? currentDate,
    int? year,
    String? month,
    bool? isActive,
  }) => DateCubitState(
    isOpen: isOpen ?? this.isOpen,
    currentDate: currentDate ?? this.currentDate,
    year: year ?? this.year,
    month: month ?? this.month,
    isActive: isActive ?? this.isActive,
  );
}
