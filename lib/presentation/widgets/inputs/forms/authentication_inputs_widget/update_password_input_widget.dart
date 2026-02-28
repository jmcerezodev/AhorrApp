import 'package:ahorrapp/presentation/bloc/cubits.dart';
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
  
  void isCurrentPasswordVisible(BuildContext context, bool value){
    context.read<UpdatePasswordCubit>().isCurrentPasswordVisible(value);
  }

  void isNewPasswordVisible(BuildContext context, bool value){
    context.read<UpdatePasswordCubit>().isNewPasswordVisible(value);
  }

  void isConfirmedPasswordVisible(BuildContext context, bool value){
    context.read<UpdatePasswordCubit>().isConfirmedPasswordVisible(value);
  }

  @override
  Widget build(BuildContext context) {
    final updatePasswordCubit = context.watch<UpdatePasswordCubit>();
  
    final currentPassword = updatePasswordCubit.state.currentPassword;
    final newPassword = updatePasswordCubit.state.newPassword;
    final confirmedPassword = updatePasswordCubit.state.confirmedPassword;

    return Column(
      children: [
        CustomInputTextWidget(
          prefixIcon: Icons.lock_outline_rounded,
          suffixIcon: (updatePasswordCubit.state.currentPasswordEncripted == false) 
          ? Icons.visibility_outlined 
          : Icons.visibility_off_outlined,
          onPressedSuffixIcon: (){
            isCurrentPasswordVisible(context, !updatePasswordCubit.state.currentPasswordEncripted);
          },
          label: 'Contraseña Actual',
          obscureText: updatePasswordCubit.state.currentPasswordEncripted,
          autoFocus: false,
          onChanged: updatePasswordCubit.currentPasswordChanged,
          errorText: currentPassword.isPure ? null : currentPassword.errorMessage,
          textCapitalization: TextCapitalization.none,
        ),

        const SizedBox(height: 15),

        CustomInputTextWidget(
          prefixIcon: Icons.lock_reset_rounded,
          suffixIcon: (updatePasswordCubit.state.newPasswordEncripted == false) 
          ? Icons.visibility_outlined 
          : Icons.visibility_off_outlined,
          onPressedSuffixIcon: (){
            isNewPasswordVisible(context, !updatePasswordCubit.state.newPasswordEncripted);
          },
          label: 'Nueva Contraseña',
          obscureText:updatePasswordCubit.state.newPasswordEncripted,
          autoFocus: false,
          onChanged: updatePasswordCubit.newPasswordChanged,
          errorText: newPassword.isPure ? null : newPassword.errorMessage,
          textCapitalization: TextCapitalization.none,
        ),

        const SizedBox(height: 15),

        CustomInputTextWidget(
          prefixIcon: Icons.verified_user_outlined,
          suffixIcon: (updatePasswordCubit.state.confirmedPasswordEncripted == false) 
          ? Icons.visibility_outlined 
          : Icons.visibility_off_outlined,
          onPressedSuffixIcon: (){
            isConfirmedPasswordVisible(context, !updatePasswordCubit.state.confirmedPasswordEncripted);
          },
          label: 'Confirma la Contraseña',
          obscureText: updatePasswordCubit.state.confirmedPasswordEncripted,
          autoFocus: false,
          onChanged: updatePasswordCubit.confirmedPasswordChanged,
          errorText: confirmedPassword.isPure ? null : confirmedPassword.errorMessage,
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
                onPressed: updatePasswordCubit.state.isValid 
                ? () async {
                  updatePasswordCubit.onSubmit(context);
                } 
                : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('CAMBIAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
