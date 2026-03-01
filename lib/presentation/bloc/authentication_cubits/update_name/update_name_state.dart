part of 'update_name_cubit.dart';

enum UpdateNameStatus { initial, submitting, success, failure }

class UpdateNameState extends Equatable {
  final String name;
  final UpdateNameStatus status;
  final Name newName;
  final bool isValid;
  final String? errorMessage;

  const UpdateNameState({
    required this.name,
    this.status = UpdateNameStatus.initial,
    this.newName = const Name.pure(),
    this.isValid = false,
    this.errorMessage,
  });

  UpdateNameState copyWith({
    String? name,
    UpdateNameStatus? status,
    Name? newName,
    bool? isValid,
    String? errorMessage,
  }) =>
      UpdateNameState(
        name: name ?? this.name,
        status: status ?? this.status,
        newName: newName ?? this.newName,
        isValid: isValid ?? this.isValid,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [name, status, newName, isValid, errorMessage];
}
