part of 'update_password_cubit.dart';

enum FormStatusUpdatePassword { invalid, valid, validating }

class UpdatePasswordState extends Equatable {
  final FormStatusUpdatePassword formStatus;
  final bool isValid;
  final Password currentPassword;
  final NewPassword newPassword;
  final ConfirmedPassword confirmedPassword;
  final bool currentPasswordEncripted;
  final bool newPasswordEncripted;
  final bool confirmedPasswordEncripted;

  const UpdatePasswordState({
    this.formStatus = FormStatusUpdatePassword.invalid,
    this.isValid = false,
    this.currentPassword = const Password.pure(),
    this.newPassword = const NewPassword.pure(),
    this.confirmedPassword = const ConfirmedPassword.pure(),
    this.currentPasswordEncripted = true,
    this.newPasswordEncripted = true,
    this.confirmedPasswordEncripted = true,
  });

  UpdatePasswordState copyWith({
    FormStatusUpdatePassword? formStatus,
    bool? isValid,
    Password? currentPassword,
    NewPassword? newPassword,
    ConfirmedPassword? confirmedPassword,
    bool? currentPasswordEncripted,
    bool? newPasswordEncripted,
    bool? confirmedPasswordEncripted,
  }) =>
      UpdatePasswordState(
        formStatus: formStatus ?? this.formStatus,
        isValid: isValid ?? this.isValid,
        currentPassword: currentPassword ?? this.currentPassword,
        newPassword: newPassword ?? this.newPassword,
        confirmedPassword: confirmedPassword ?? this.confirmedPassword,
        currentPasswordEncripted: currentPasswordEncripted ?? this.currentPasswordEncripted,
        newPasswordEncripted: newPasswordEncripted ?? this.newPasswordEncripted,
        confirmedPasswordEncripted: confirmedPasswordEncripted ?? this.confirmedPasswordEncripted,
      );

  @override
  List<Object?> get props => [
        formStatus,
        isValid,
        currentPassword,
        newPassword,
        confirmedPassword,
        currentPasswordEncripted,
        newPasswordEncripted,
        confirmedPasswordEncripted,
      ];
}
