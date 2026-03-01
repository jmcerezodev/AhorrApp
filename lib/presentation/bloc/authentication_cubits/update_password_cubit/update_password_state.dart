part of 'update_password_cubit.dart';

enum UpdatePasswordStatus { initial, submitting, success, failure }

class UpdatePasswordState extends Equatable {
  final bool isValid;
  final UpdatePasswordStatus status;
  final Password currentPassword;
  final NewPassword newPassword;
  final ConfirmedPassword confirmedPassword;
  final bool currentPasswordEncripted;
  final bool newPasswordEncripted;
  final bool confirmedPasswordEncripted;
  final String? errorMessage;

  const UpdatePasswordState({
    this.isValid = false,
    this.status = UpdatePasswordStatus.initial,
    this.currentPassword = const Password.pure(),
    this.newPassword = const NewPassword.pure(),
    this.confirmedPassword = const ConfirmedPassword.pure(),
    this.currentPasswordEncripted = true,
    this.newPasswordEncripted = true,
    this.confirmedPasswordEncripted = true,
    this.errorMessage,
  });

  UpdatePasswordState copyWith({
    bool? isValid,
    UpdatePasswordStatus? status,
    Password? currentPassword,
    NewPassword? newPassword,
    ConfirmedPassword? confirmedPassword,
    bool? currentPasswordEncripted,
    bool? newPasswordEncripted,
    bool? confirmedPasswordEncripted,
    String? errorMessage,
  }) =>
      UpdatePasswordState(
        isValid: isValid ?? this.isValid,
        status: status ?? this.status,
        currentPassword: currentPassword ?? this.currentPassword,
        newPassword: newPassword ?? this.newPassword,
        confirmedPassword: confirmedPassword ?? this.confirmedPassword,
        currentPasswordEncripted: currentPasswordEncripted ?? this.currentPasswordEncripted,
        newPasswordEncripted: newPasswordEncripted ?? this.newPasswordEncripted,
        confirmedPasswordEncripted: confirmedPasswordEncripted ?? this.confirmedPasswordEncripted,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [
        isValid,
        status,
        currentPassword,
        newPassword,
        confirmedPassword,
        currentPasswordEncripted,
        newPasswordEncripted,
        confirmedPasswordEncripted,
        errorMessage
      ];
}
