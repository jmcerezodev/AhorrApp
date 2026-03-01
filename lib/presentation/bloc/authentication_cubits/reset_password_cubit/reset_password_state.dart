part of 'reset_password_cubit.dart';

enum ResetPasswordStatus { initial, submitting, success, failure }

class ResetPasswordState extends Equatable {
  final ResetPasswordStatus status;
  final bool isValid;
  final Email resetPassword;
  final String? errorMessage;

  const ResetPasswordState({
    this.status = ResetPasswordStatus.initial,
    this.isValid = false,
    this.resetPassword = const Email.pure(),
    this.errorMessage,
  });

  ResetPasswordState copyWith({
    ResetPasswordStatus? status,
    bool? isValid,
    Email? resetPassword,
    String? errorMessage,
  }) => ResetPasswordState(
    status: status ?? this.status,
    isValid: isValid ?? this.isValid,
    resetPassword: resetPassword ?? this.resetPassword,
    errorMessage: errorMessage ?? this.errorMessage,
  );
  
  @override
  List<Object?> get props => [status, isValid, resetPassword, errorMessage];
}
