part of 'savings_cubit.dart';

enum FormStatusSavings {invalid, valid, validating}

class SavingsCubitState extends Equatable{

  final bool isValid;
  final FormStatusSavings formStatus;
  final SavingInput saving;
  final double savingTotal;
  final double savingGoal;
  final List<Map<String, dynamic>> savingsList; // NUEVO: Lista de aportaciones

  const SavingsCubitState({
    this.formStatus = FormStatusSavings.invalid,
    this.isValid = false,
    this.saving = const SavingInput.pure(),
    this.savingTotal = 0,
    this.savingGoal = 0,
    this.savingsList = const [],
  });

  double get progress {
    if (savingGoal <= 0) return 0.0;
    final p = savingTotal / savingGoal;
    return p > 1.0 ? 1.0 : p;
  }

  SavingsCubitState copyWhith({
    FormStatusSavings? formStatus,
    bool? isValid,
    SavingInput? saving,
    double? savingTotal,
    double? savingGoal,
    List<Map<String, dynamic>>? savingsList,
  }) => SavingsCubitState(
    formStatus: formStatus ?? this.formStatus,
    isValid: isValid ?? this.isValid,
    saving: saving ?? this.saving,
    savingTotal: savingTotal ?? this.savingTotal,
    savingGoal: savingGoal ?? this.savingGoal,
    savingsList: savingsList ?? this.savingsList,
  );
  
  @override
  List<Object?> get props => [formStatus, isValid, saving, savingTotal, savingGoal, savingsList];
}
