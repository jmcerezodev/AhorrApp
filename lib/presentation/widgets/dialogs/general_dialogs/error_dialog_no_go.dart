import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ErrorDialogNoGo extends StatelessWidget {

  final String textError;
  
  const ErrorDialogNoGo({
    super.key,
    required this.textError,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomDialogWrapper(
      borderColor: Colors.red.shade400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 100),
          const SizedBox(height: 10),

          AppDialogs.dialogMessage(textError, colorScheme),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  'CERRAR',
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.4), 
                    fontWeight: FontWeight.bold, 
                    letterSpacing: 1
                  )
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
