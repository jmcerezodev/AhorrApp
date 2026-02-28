part of 'update_name_cubit.dart';

enum FormStatusUpdateName{invalid, valid, validating}

class UpdateNameState extends Equatable {
  final FormStatusUpdateName formStatus;
  final bool isValid;
  final String name;
  final Name newName;

  const UpdateNameState({
    this.formStatus = FormStatusUpdateName.invalid,
    this.isValid = false,
    this.name = '',
    this.newName = const Name.pure(),
  });

  UpdateNameState copyWhith({
    FormStatusUpdateName? formStatus,
    bool? isValid,
    String? name,
    Name? newName,
    
  }) => UpdateNameState (
    formStatus: formStatus ?? this.formStatus,
    isValid: isValid ?? this.isValid,
    name: name ?? this.name,
    newName: newName ?? this.newName,
  );

  @override
  List<Object> get props => [name, newName];
}

