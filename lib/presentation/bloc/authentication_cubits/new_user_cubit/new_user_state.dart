part of 'new_user_cubit.dart';

enum NewUserStatus { initial, submitting, success, failure }

class NewUserCubitState extends Equatable {
  final bool isValid;
  final NewUserStatus status;
  final Name name;
  final Email email;
  final Password password;
  final bool passwordEncripted;
  final String? errorMessage;

  const NewUserCubitState({
    this.status = NewUserStatus.initial,
    this.isValid = false,
    this.name = const Name.pure(),
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.passwordEncripted = true,
    this.errorMessage,
  });

  NewUserCubitState copyWith({
    NewUserStatus? status,
    bool? isValid,
    Name? name,
    Email? email,
    Password? password,
    bool? passwordEncripted,
    String? errorMessage,
  }) => NewUserCubitState(
    status: status ?? this.status,
    isValid: isValid ?? this.isValid,
    name: name ?? this.name,
    email: email ?? this.email,
    password: password ?? this.password,
    passwordEncripted: passwordEncripted ?? this.passwordEncripted,
    errorMessage: errorMessage ?? this.errorMessage,
  );
  
  @override
  List<Object?> get props => [status, isValid, name, email, password, passwordEncripted, errorMessage];
}
