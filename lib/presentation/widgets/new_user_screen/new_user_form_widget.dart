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
    final newUserCubit = context.watch<NewUserCubit>();
    final nameCubit = newUserCubit.state.name;
    final emailCubit = newUserCubit.state.email;
    final passwordCubit = newUserCubit.state.password;

    return BlocListener<NewUserCubit, NewUserCubitState>(
      listener: (context, state) {
        // 1. Éxito: Navegamos a la Home
        if (state.status == NewUserStatus.success) {
          context.go('/home-screen');
        } 
        
        // 2. Fallo: Mostramos el error detallado que viene de Appwrite
        else if (state.status == NewUserStatus.failure) {
          showDialog(
            context: context, 
            builder: (context) => AuthErrorDialog(
              errorTitle: '!Se ha producido un error!', 
              errorText: state.errorMessage ?? 'No se pudo crear la cuenta. Verifica tu conexión.',
            ),
          );
        }
      },
      child: Form(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              'REGISTRO',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade400,
                letterSpacing: 3.0,
              ),
            ),
            const SizedBox(height: 25),

            //* Nombre
            CustomInputTextWidget(
              prefixIcon: Icons.person_outline_rounded,
              label: 'Tu Nombre',
              hintText: 'Nombre',
              onChanged: newUserCubit.nameChanged,
              errorText: nameCubit.errorMessage,
              autoFocus: false,
              textInputType: TextInputType.name,
              textCapitalization: TextCapitalization.sentences,
            ),
            
            const SizedBox(height: 20),

            //* Correo Electronico
            CustomInputTextWidget(
              prefixIcon: Icons.email_outlined,
              label: 'Correo Electronico',
              hintText: 'tucorreo@correo.com',
              onChanged:  newUserCubit.emailChanged,
              errorText: emailCubit.errorMessage,
              autoFocus: false,
              textInputType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
            ),
            
            const SizedBox(height: 20),

            //* Contraseña
            CustomInputTextWidget(
              prefixIcon: Icons.key_outlined,
              suffixIcon: (newUserCubit.state.passwordEncripted == false) 
              ? Icons.visibility_outlined 
              : Icons.visibility_off_outlined,
              onPressedSuffixIcon: () => isPasswordVisible(context),
              label: 'Contraseña',
              obscureText: newUserCubit.state.passwordEncripted,
              autoFocus: false,
              onChanged: newUserCubit.passwordChanged,
              errorText: passwordCubit.errorMessage,
              textCapitalization: TextCapitalization.none,
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                // 3. Deshabilitar botón mientras se envía (submitting)
                onPressed: newUserCubit.state.status == NewUserStatus.submitting
                  ? null
                  : () => newUserCubit.onSubmit(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                icon: newUserCubit.state.status == NewUserStatus.submitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.person_add_rounded),
                label: const Text(
                  'CREAR CUENTA', 
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.2)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
