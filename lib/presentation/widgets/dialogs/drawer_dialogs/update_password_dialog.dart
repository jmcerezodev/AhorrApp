import 'package:ahorrapp/presentation/bloc/authentication_cubits/update_password_cubit/update_password_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:ahorrapp/presentation/widgets/inputs/forms/authentication_inputs_widget/update_password_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdatePasswordDialog extends StatelessWidget {
  final String title;
  final String text;
  
  const UpdatePasswordDialog({
    super.key, 
    required this.title, 
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => UpdatePasswordCubit(),
      child: CustomDialogWrapper(
        borderColor: Colors.orange.withValues(alpha: isDark ? 0.2 : 0.4),
        horizontalInsetPadding: 20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppDialogs.dialogRowHeader(
              icon: Icons.lock_reset_rounded, 
              title: 'Cambiar Contraseña', 
              color: Colors.orange, 
              colorScheme: colorScheme
            ),
            const SizedBox(height: 25),
    
            const UpdatePasswordInputWidget(),
          ],
        ),
      ),
    );
  }
}
