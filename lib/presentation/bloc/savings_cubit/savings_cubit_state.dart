part of 'savings_cubit.dart';

enum SavingsStatus { initial, loading, success, failure }

class SavingsCubitState extends Equatable {
  final bool isValid;
  final SavingsStatus status;
  final SavingInput saving;
  final double savingTotal;
  final double savingGoal;
  final List<Map<String, dynamic>> savingsList;
  final String? errorMessage;

  const SavingsCubitState({
    this.isValid = false,
    this.status = SavingsStatus.initial,
    this.saving = const SavingInput.pure(),
    this.savingTotal = 0,
    this.savingGoal = 0,
    this.savingsList = const [],
    this.errorMessage,
  });

  double get progress {
    if (savingGoal <= 0) return 0.0;
    final p = savingTotal / savingGoal;
    return p > 1.0 ? 1.0 : p;
  }

  SavingsCubitState copyWith({
    SavingsStatus? status,
    bool? isValid,
    SavingInput? saving,
    double? savingTotal,
    double? savingGoal,
    List<Map<String, dynamic>>? savingsList,
    String? errorMessage,
  }) =>
      SavingsCubitState(
        status: status ?? this.status,
        isValid: isValid ?? this.isValid,
        saving: saving ?? this.saving,
        savingTotal: savingTotal ?? this.savingTotal,
        savingGoal: savingGoal ?? this.savingGoal,
        savingsList: savingsList ?? this.savingsList,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, isValid, saving, savingTotal, savingGoal, savingsList, errorMessage];
}
