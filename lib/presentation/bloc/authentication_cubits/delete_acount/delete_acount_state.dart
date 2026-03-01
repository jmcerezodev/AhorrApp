part of 'delete_acount_cubit.dart';

enum DeleteAccountStatus { initial, submitting, success, failure }

class DeleteCubitState extends Equatable {
  final String deleteAcountValueInput;
  final DeleteAccountStatus status;
  final String? errorMessage;

  const DeleteCubitState({
    this.deleteAcountValueInput = '',
    this.status = DeleteAccountStatus.initial,
    this.errorMessage,
  });

  DeleteCubitState copyWith({
    String? deleteAcountValueInput,
    DeleteAccountStatus? status,
    String? errorMessage,
  }) =>
      DeleteCubitState(
        deleteAcountValueInput: deleteAcountValueInput ?? this.deleteAcountValueInput,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [deleteAcountValueInput, status, errorMessage];
}
