part of 'savings_cubit.dart';

enum FormStatusSavings {invalid, valid, validating}

class SavingsCubitState extends Equatable{

  final bool isValid;
  final FormStatusSavings formStatus;
  final SavingInput saving;
  final double savingTotal;

  const SavingsCubitState({
    this.formStatus = FormStatusSavings.invalid,
    this.isValid = false,
    this.saving = const SavingInput.pure(),
    this.savingTotal = 0,
  });

  SavingsCubitState copyWhith({
    FormStatusSavings? formStatus,
    bool? isValid,
    SavingInput? saving,
    double? savingTotal,
  }) => SavingsCubitState(
    formStatus: formStatus ?? this.formStatus,
    isValid: isValid ?? this.isValid,
    saving: saving ?? this.saving,
    savingTotal: savingTotal ?? this.savingTotal,
  );
  
  @override
  List<Object?> get props => [formStatus, isValid, saving, savingTotal];
}


