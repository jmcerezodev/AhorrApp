import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SuccessfulDialog extends StatelessWidget {
  final String sucessfulName;
  final String routeScreen;
  final Widget? extraContent;
  
  const SuccessfulDialog({
    super.key, 
    required this.sucessfulName, 
    required this.routeScreen,
    this.extraContent,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomDialogWrapper(
      borderColor: Colors.green.shade400.withValues(alpha: isDark ? 0.2 : 0.4),
      horizontalInsetPadding: 30,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDialogs.dialogHeader(
            icon: Icons.check_circle_outline_rounded, 
            color: Colors.green.shade400, 
            title: '¡ÉXITO!',
            circularBackground: true,
            iconSize: 40,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 15),
          
          AppDialogs.dialogMessage('¡$sucessfulName correctamente!', colorScheme),
          
          if (extraContent != null) ...[
            const SizedBox(height: 20),
            extraContent!,
          ],

          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: AppDialogs.dialogPrimaryButton(
              text: 'CONTINUAR', 
              onPressed: () {
                context.pop();
                context.go(routeScreen);
              }, 
              color: Colors.green.shade600
            ),
          ),
        ],
      ),
    );
  }
}
