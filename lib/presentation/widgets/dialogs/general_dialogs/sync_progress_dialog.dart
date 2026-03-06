import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:flutter/material.dart';

class SyncProgressDialog extends StatelessWidget {
  final double progress;
  const SyncProgressDialog({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomDialogWrapper(
      borderColor: colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.4),
      animate: false,
      child: PopScope(
        canPop: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppDialogs.dialogHeader(
              icon: Icons.sync_rounded, 
              color: colorScheme.primary, 
              title: 'SINCRONIZANDO DATOS',
              circularBackground: true,
              iconSize: 32,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 15),
            
            AppDialogs.dialogMessage(
              'Estamos preparando tu balance global por primera vez. Solo tardará unos segundos...', 
              colorScheme
            ),
            const SizedBox(height: 30),
            
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
