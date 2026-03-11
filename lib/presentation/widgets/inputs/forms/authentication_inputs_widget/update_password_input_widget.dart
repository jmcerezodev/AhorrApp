import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/dialogs.dart';
import 'package:ahorrapp/presentation/widgets/inputs/inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class UpdatePasswordInputWidget extends StatefulWidget {
  const UpdatePasswordInputWidget({super.key});

  @override
  State<UpdatePasswordInputWidget> createState() => _UpdatePasswordInputWidgetState();
}

class _UpdatePasswordInputWidgetState extends State<UpdatePasswordInputWidget> {
  // Bandera para saber si el usuario ya intentó enviar el formulario
  bool _formSubmitted = false;
  
  void isCurrentPasswordVisible(BuildContext context){
    context.read<UpdatePasswordCubit>().isCurrentPasswordVisible();
  }

  void isNewPasswordVisible(BuildContext context){
    context.read<UpdatePasswordCubit>().isNewPasswordVisible();
  }

  void isConfirmedPasswordVisible(BuildContext context){
    context.read<UpdatePasswordCubit>().isConfirmedPasswordVisible();
  }

  @override
  Widget build(BuildContext context) {
    final updatePasswordCubit = context.watch<UpdatePasswordCubit>();
  
    final currentPassword = updatePasswordCubit.state.currentPassword;
    final newPassword = updatePasswordCubit.state.newPassword;
    final confirmedPassword = updatePasswordCubit.state.confirmedPassword;

    return BlocListener<UpdatePasswordCubit, UpdatePasswordState>(
      listener: (context, state) {
        if (state.status == UpdatePasswordStatus.success) {
          context.pop(); // Cierra el diálogo de edición
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (dialogContext) => const SuccessfulDialog(
              sucessfulName: 'Contraseña Cambiada',
              routeScreen: '/home-screen',
            ),
          );
        } else if (state.status == UpdatePasswordStatus.failure) {
          showDialog(
            context: context,
            builder: (dialogContext) => ErrorDialog(
              errorMessage: state.errorMessage ?? '!Se ha producido un Error!\n La contraseña no ha cambiado',
            ),
          );
        }
      },
      child: Column(
        children: [
          CustomInputTextWidget(
            prefixIcon: Icons.lock_outline_rounded,
            suffixIcon: (updatePasswordCubit.state.currentPasswordEncripted == false) 
            ? Icons.visibility_outlined 
            : Icons.visibility_off_outlined,
            onPressedSuffixIcon: (){
              isCurrentPasswordVisible(context);
            },
            label: 'Contraseña Actual',
            obscureText: updatePasswordCubit.state.currentPasswordEncripted,
            autoFocus: false,
            onChanged: updatePasswordCubit.currentPasswordChanged,
            errorText: _formSubmitted ? currentPassword.errorMessage : null,
            textCapitalization: TextCapitalization.none,
          ),
  
          const SizedBox(height: 15),
  
          CustomInputTextWidget(
            prefixIcon: Icons.lock_reset_rounded,
            suffixIcon: (updatePasswordCubit.state.newPasswordEncripted == false) 
            ? Icons.visibility_outlined 
            : Icons.visibility_off_outlined,
            onPressedSuffixIcon: (){
              isNewPasswordVisible(context);
            },
            label: 'Nueva Contraseña',
            obscureText:updatePasswordCubit.state.newPasswordEncripted,
            autoFocus: false,
            onChanged: updatePasswordCubit.newPasswordChanged,
            errorText: _formSubmitted ? newPassword.errorMessage : null,
            textCapitalization: TextCapitalization.none,
          ),
  
          const SizedBox(height: 15),
  
          CustomInputTextWidget(
            prefixIcon: Icons.verified_user_outlined,
            suffixIcon: (updatePasswordCubit.state.confirmedPasswordEncripted == false) 
            ? Icons.visibility_outlined 
            : Icons.visibility_off_outlined,
            onPressedSuffixIcon: (){
              isConfirmedPasswordVisible(context);
            },
            label: 'Confirma la Contraseña',
            obscureText: updatePasswordCubit.state.confirmedPasswordEncripted,
            autoFocus: false,
            onChanged: updatePasswordCubit.confirmedPasswordChanged,
            errorText: _formSubmitted ? confirmedPassword.errorMessage : null,
            textCapitalization: TextCapitalization.none,
          ),
  
          const SizedBox(height: 30),
  
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    updatePasswordCubit.resetCubit();
                    context.pop();
                  },
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                  child: Text('CANCELAR', style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  onPressed: updatePasswordCubit.state.status == UpdatePasswordStatus.submitting 
                    ? null 
                    : () {
                        setState(() => _formSubmitted = true);
                        updatePasswordCubit.onSubmit();
                      },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: updatePasswordCubit.state.status == UpdatePasswordStatus.submitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('CAMBIAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
