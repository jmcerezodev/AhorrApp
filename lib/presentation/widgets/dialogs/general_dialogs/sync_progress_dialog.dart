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
      borderColor: Colors.orange.withValues(alpha: isDark ? 0.2 : 0.4),
      animate: false,
      child: PopScope(
        canPop: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppDialogs.dialogHeader(
              icon: Icons.sync_rounded, 
              color: Colors.orange, 
              title: 'Sincronizando Datos',
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 20),
            
            AppDialogs.dialogMessage(
              'Estamos preparando tu balance global por primera vez. Solo tardará unos segundos...', 
              colorScheme
            ),
            const SizedBox(height: 30),
            
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.orange.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.orange,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
