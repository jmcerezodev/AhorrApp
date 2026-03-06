import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ErrorDateDialog extends StatelessWidget {
  final String textDialog;
  
  const ErrorDateDialog({
    super.key, 
    required this.textDialog
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomDialogWrapper(
      borderColor: colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.4),
      horizontalInsetPadding: 30,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDialogs.dialogHeader(
            icon: Icons.calendar_today_rounded, 
            color: colorScheme.primary, 
            title: 'RESTRICCIÓN DE FECHA',
            circularBackground: true,
            iconSize: 32,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 15),
          
          AppDialogs.dialogMessage(textDialog, colorScheme),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: AppDialogs.dialogPrimaryButton(
              text: 'ENTENDIDO', 
              onPressed: () => context.pop(), 
              color: colorScheme.primary
            ),
          ),
        ],
      ),
    );
  }
}
