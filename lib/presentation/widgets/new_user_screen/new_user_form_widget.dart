import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/dialogs.dart';
import 'package:ahorrapp/presentation/widgets/inputs/inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class UserInputWidget extends StatefulWidget {
  const UserInputWidget({super.key});

  @override
  State<UserInputWidget> createState() => _UserInputWidgetState();
}

class _UserInputWidgetState extends State<UserInputWidget> {
  
  void isPasswordVisible(BuildContext context) {
    context.read<NewUserCubit>().isPasswordVisible();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final newUserCubit = context.watch<NewUserCubit>();
    
    final nameCubit = newUserCubit.state.name;
    final emailCubit = newUserCubit.state.email;
    final passwordCubit = newUserCubit.state.password;

    return BlocListener<NewUserCubit, NewUserCubitState>(
      listener: (context, state) {
        if (state.formStatus == FormStatusNewUser.valid) {
          context.go('/home-screen');
        } else if (state.formStatus == FormStatusNewUser.invalid) {
          showDialog(
            context: context, 
            builder: (context) => const AuthErrorDialog(
              errorTitle: '!Se ha producido un error!', 
              errorText: 'No se pudo crear la cuenta. Es posible que el correo ya esté en uso o haya un error de conexión.',
            ),
          );
        }
      },
      child: Form(
        child: Column(
          children: [
            SizedBox(height: size.height * 0.02),
            const Text('Crea nueva cuenta', style: TextStyle(fontWeight: FontWeight.bold),),
            SizedBox(height: size.height * 0.02),

            //* Nombre
            CustomInputTextWidget(
              prefixIcon: Icons.person,
              label: 'Tu Nombre',
              hintText: 'Nombre',
              onChanged: newUserCubit.nameChanged,
              errorText: nameCubit.errorMessage,
              autoFocus: false,
              textInputType: TextInputType.name,
              textCapitalization: TextCapitalization.sentences,
            ),
            
            SizedBox(height: size.height * 0.02),

            //* Correo Electronico
            CustomInputTextWidget(
              prefixIcon: Icons.email,
              label: 'Correo Electronico',
              hintText: 'tucorreo@correo.com',
              onChanged:  newUserCubit.emailChanged,
              errorText: emailCubit.errorMessage,
              autoFocus: false,
              textInputType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
            ),
            
            SizedBox(height: size.height * 0.02),

            //* Contraseña
            CustomInputTextWidget(
              prefixIcon: Icons.key,
              suffixIcon: (newUserCubit.state.passwordEncripted == false) 
              ? Icons.visibility 
              : Icons.visibility_off,
              onPressedSuffixIcon: () => isPasswordVisible(context),
              label: 'Contraseña',
              obscureText: newUserCubit.state.passwordEncripted,
              autoFocus: false,
              onChanged: newUserCubit.passwordChanged,
              errorText: passwordCubit.errorMessage,
              textCapitalization: TextCapitalization.none,
            ),

            SizedBox(height: size.height * 0.03),

            FilledButton.tonalIcon(
              onPressed: newUserCubit.state.formStatus == FormStatusNewUser.validating
                ? null
                : () => newUserCubit.onSubmit(),
              icon: newUserCubit.state.formStatus == FormStatusNewUser.validating
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.person_add),
              label: const Text('Crear Cuenta', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
