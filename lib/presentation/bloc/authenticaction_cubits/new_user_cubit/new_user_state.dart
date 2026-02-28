part of 'new_user_cubit.dart';

enum FormStatusNewUser {invalid, valid, validating}

class NewUserCubitState  extends Equatable{

  final bool isValid;
  final FormStatusNewUser formStatus;
  final Name name;
  final Email email;
  final Password password;
  final bool passwordEncripted;
  final Map<String, dynamic> loginData;

  const NewUserCubitState({
    this.formStatus = FormStatusNewUser.invalid,
    this.isValid = false,
    this.name = const Name.pure(),
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.passwordEncripted = true,
    this.loginData = const 
      {
      
      'name'     : '',
      'email'    : 'true',
      'password' : '',

      },
  });

  NewUserCubitState copyWhith({
    FormStatusNewUser? formStatus,
    bool? isValid,
    Name? name,
    Email? email,
    Password? password,
    bool? passwordEncripted,
    
    Map<String, dynamic>? loginData,
  }) => NewUserCubitState(
    formStatus: formStatus ?? this.formStatus,
    isValid: isValid ?? this.isValid,
    name: name ?? this.name,
    email: email ?? this.email,
    password: password ?? this.password,
    passwordEncripted: passwordEncripted ?? this.passwordEncripted,
    loginData: loginData ?? this.loginData,
  );
  
  @override
  
  List<Object?> get props => [formStatus, isValid, name, email, password, passwordEncripted];
}
