import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ErrorDialog extends StatelessWidget {
  final String errorMessage;
  
  const ErrorDialog({
    super.key, 
    this.errorMessage = 'Se ha producido un error',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomDialogWrapper(
      borderColor: Colors.red.shade400.withValues(alpha: isDark ? 0.2 : 0.4),
      horizontalInsetPadding: 30,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDialogs.dialogHeader(
            icon: Icons.error_outline_rounded, 
            color: Colors.red.shade400, 
            title: '¡HA OCURRIDO UN ERROR!',
            circularBackground: true,
            iconSize: 40,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 15),
          
          AppDialogs.dialogMessage(errorMessage, colorScheme),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: AppDialogs.dialogPrimaryButton(
              text: 'REINTENTAR', 
              onPressed: () => context.pop(), 
              color: Colors.red.shade400
            ),
          ),
        ],
      ),
    );
  }
}
