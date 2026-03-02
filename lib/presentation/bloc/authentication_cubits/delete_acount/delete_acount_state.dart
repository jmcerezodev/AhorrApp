part of 'delete_acount_cubit.dart';

enum DeleteAccountStatus { initial, submitting, success, failure }

class DeleteCubitState extends Equatable {
  final String deleteAcountValueInput;
  final DeleteAccountStatus status;
  final String? errorMessage;
  final double deleteProgress; // Nuevo: de 0.0 a 1.0

  const DeleteCubitState({
    this.deleteAcountValueInput = '',
    this.status = DeleteAccountStatus.initial,
    this.errorMessage,
    this.deleteProgress = 0.0,
  });

  DeleteCubitState copyWith({
    String? deleteAcountValueInput,
    DeleteAccountStatus? status,
    String? errorMessage,
    double? deleteProgress,
  }) =>
      DeleteCubitState(
        deleteAcountValueInput: deleteAcountValueInput ?? this.deleteAcountValueInput,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
        deleteProgress: deleteProgress ?? this.deleteProgress,
      );

  @override
  List<Object?> get props => [deleteAcountValueInput, status, errorMessage, deleteProgress];
}
