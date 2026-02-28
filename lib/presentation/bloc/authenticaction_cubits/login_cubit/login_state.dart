part of 'login_cubit.dart';

enum FormStatusLogin {invalid, valid, validating, editing}

class LoginCubitState extends Equatable {
  final bool isValid;
  final FormStatusLogin formStatus;
  final EmailLogin email;
  final PasswordLogin password;
  final bool passwordEncripted;
  final bool isRemember; // Añadido
  final Map<String, dynamic> loginData;

  const LoginCubitState({
    this.formStatus = FormStatusLogin.editing,
    this.isValid = false,
    this.email = const EmailLogin.pure(),
    this.password = const PasswordLogin.pure(),
    this.passwordEncripted = true,
    this.isRemember = false, // Por defecto no recordar
    this.loginData = const {
      'email': '',
      'password': '',
    },
  });

  LoginCubitState copyWhith({
    FormStatusLogin? formStatus,
    bool? isValid,
    EmailLogin? email,
    PasswordLogin? password,
    bool? passwordEncripted,
    bool? isRemember,
    Map<String, dynamic>? loginData,
  }) => LoginCubitState(
    formStatus: formStatus ?? this.formStatus,
    isValid: isValid ?? this.isValid,
    email: email ?? this.email,
    password: password ?? this.password,
    passwordEncripted: passwordEncripted ?? this.passwordEncripted,
    isRemember: isRemember ?? this.isRemember, // Actualizado
    loginData: loginData ?? this.loginData,
  );
  
  @override
  List<Object?> get props => [formStatus, isValid, email, password, passwordEncripted, isRemember];
}
