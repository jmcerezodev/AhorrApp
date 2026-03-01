part of 'login_cubit.dart';

enum LoginStatus { initial, submitting, success, failure }

class LoginCubitState extends Equatable {
  final bool isValid;
  final LoginStatus status; // Unificado a 'status'
  final EmailLogin email;
  final PasswordLogin password;
  final bool passwordEncripted;
  final bool isRemember; 
  final String? errorMessage;

  const LoginCubitState({
    this.status = LoginStatus.initial,
    this.isValid = false,
    this.email = const EmailLogin.pure(),
    this.password = const PasswordLogin.pure(),
    this.passwordEncripted = true,
    this.isRemember = false, 
    this.errorMessage,
  });

  LoginCubitState copyWith({
    LoginStatus? status,
    bool? isValid,
    EmailLogin? email,
    PasswordLogin? password,
    bool? passwordEncripted,
    bool? isRemember,
    String? errorMessage,
  }) => LoginCubitState(
    status: status ?? this.status,
    isValid: isValid ?? this.isValid,
    email: email ?? this.email,
    password: password ?? this.password,
    passwordEncripted: passwordEncripted ?? this.passwordEncripted,
    isRemember: isRemember ?? this.isRemember,
    errorMessage: errorMessage ?? this.errorMessage,
  );
  
  @override
  List<Object?> get props => [status, isValid, email, password, passwordEncripted, isRemember, errorMessage];
}
