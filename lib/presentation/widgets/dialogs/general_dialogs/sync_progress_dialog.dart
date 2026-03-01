import 'package:flutter/material.dart';

class SyncProgressDialog extends StatelessWidget {
  final double progress;
  const SyncProgressDialog({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      // ELIMINADO barrierDismissible: false, (Este parámetro va en showDialog, no en el constructor de Dialog)
      child: PopScope(
        canPop: false, // Evita cerrar el diálogo con el botón atrás
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.4), 
              width: 1.5
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.sync_rounded, color: colorScheme.primary, size: 32),
              ),
              const SizedBox(height: 20),
              Text(
                'SINCRONIZANDO DATOS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Estamos preparando tu balance global por primera vez. Solo tardará unos segundos...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              
              // Barra de progreso animada
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
      ),
    );
  }
}
