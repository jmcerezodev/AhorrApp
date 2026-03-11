import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:flutter/material.dart';

class AuthErrorDialog extends StatelessWidget {
  final String errorTitle;
  final String errorText;
  
  const AuthErrorDialog({
    super.key, 
    required this.errorTitle, 
    required this.errorText,
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
            icon: Icons.lock_person_rounded, 
            color: Colors.red.shade400, 
            title: errorTitle,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 20),
          
          AppDialogs.dialogMessage(errorText, colorScheme),
          const SizedBox(height: 30),
      
          SizedBox(
            width: double.infinity,
            child: AppDialogs.dialogPrimaryButton(
              text: 'REINTENTAR', 
              onPressed: () => Navigator.of(context).pop(), 
              color: Colors.orange
            ),
          ),
        ],
      ),
    );
  }
}
