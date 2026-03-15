import 'package:ahorrapp/core/config/responsive_utils.dart';
import 'package:ahorrapp/data/appwrite/auth_appwrite.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:flutter/material.dart';

class SingOutDialog extends StatelessWidget {
  const SingOutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthAppwrite();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomDialogWrapper(
      borderColor: Colors.red.shade400.withValues(alpha: isDark ? 0.2 : 0.4),
      horizontalInsetPadding: 30.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDialogs.dialogHeader(
            icon: Icons.logout_rounded, 
            color: Colors.red.shade400, 
            title: '¿Cerrar Sesión?',
            colorScheme: colorScheme,
          ),
          SizedBox(height: 20.h),
          
          AppDialogs.dialogMessage(
            '¿Estás seguro de que quieres salir de tu cuenta?',
            colorScheme,
          ),
          SizedBox(height: 15.h),
          AppDialogs.dialogMessage(
            'Tendrás que volver a identificarte para acceder a tus datos.',
            colorScheme,
            customColor: Colors.orange.shade700,
          ),
          SizedBox(height: 30.h),

          OverflowBar(
            spacing: 15.w,
            overflowSpacing: 10.h,
            alignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 120.w,
                child: AppDialogs.dialogSecondaryButton(
                  text: 'CANCELAR', 
                  onPressed: () => Navigator.of(context).pop(), 
                  colorScheme: colorScheme
                ),
              ),
              SizedBox(
                width: 120.w,
                child: AppDialogs.dialogPrimaryButton(
                  text: 'SALIR', 
                  onPressed: () async {
                    await authService.singOut(context);
                  }, 
                  color: Colors.red.shade400
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
