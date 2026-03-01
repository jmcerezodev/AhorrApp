part of 'reset_password_cubit.dart';

enum FormStatusResetPassword {invalid, valid, validating}

class ResetPasswordState extends Equatable {
  final bool isValid;
  final FormStatusResetPassword formStatus;
  final Email resetPassword;
  final bool passwordEncripted;
  final bool isRemember;

  const ResetPasswordState({
    this.formStatus = FormStatusResetPassword.invalid,
    this.isValid = false,
    this.resetPassword = const Email.pure(),
    this.passwordEncripted = true,
    this.isRemember = false,
  });

  ResetPasswordState copyWith({
    FormStatusResetPassword? formStatus,
    bool? isValid,
    Email? resetPassword,
    bool? passwordEncripted,
    bool? isRemember,
  }) =>
      ResetPasswordState(
        formStatus: formStatus ?? this.formStatus,
        isValid: isValid ?? this.isValid,
        resetPassword: resetPassword ?? this.resetPassword,
        passwordEncripted: passwordEncripted ?? this.passwordEncripted,
        isRemember: isRemember ?? this.isRemember,
      );

  @override
  List<Object?> get props => [formStatus, isValid, resetPassword, passwordEncripted, isRemember];
}
