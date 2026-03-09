import 'dart:io';
import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/domain/entities/ticket_item.dart';
import 'package:ahorrapp/domain/services/ticket_export_service.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/general_dialogs/successful_dialog_no_go.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TicketExportDialog extends StatelessWidget {
  final TicketItem item;

  const TicketExportDialog({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final exportService = getIt<TicketExportService>();
    final brandColor = Colors.orange.shade400;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: brandColor.withValues(alpha: isDark ? 0.2 : 0.4),
            width: 1.5
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: brandColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.ios_share_rounded, color: brandColor, size: 32),
            ),
            const SizedBox(height: 20),
            
            Text(
              'EXPORTAR TICKET',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: brandColor,
              ),
            ),
            const SizedBox(height: 25),

            _ExportOption(
              icon: Icons.image_rounded,
              label: 'GUARDAR IMAGEN',
              color: brandColor,
              onTap: () async {
                final navigator = Navigator.of(context);
                context.pop();
                if (item.imagePath != null) {
                  final result = await exportService.saveImageToGallery(File(item.imagePath!));
                  if (result != null && navigator.mounted) {
                    showDialog(
                      context: navigator.context,
                      builder: (_) => SuccessfulDialogNoGo(
                        title: '¡GUARDADO!',
                        sucessfulName: 'Ticket guardado con éxito en: $result',
                      ),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 12),
            _ExportOption(
              icon: Icons.picture_as_pdf_rounded,
              label: 'GUARDAR COMO PDF',
              color: brandColor,
              onTap: () async {
                context.pop();
                if (item.imagePath != null) {
                  // Usamos la interfaz de impresión del sistema que permite "Guardar como PDF" directamente
                  // saltándose las restricciones de privacidad de carpetas.
                  await exportService.savePdfWithSystem(File(item.imagePath!), 'ticket_${item.name}');
                }
              },
            ),
            const SizedBox(height: 12),
            _ExportOption(
              icon: Icons.share_rounded,
              label: 'COMPARTIR TICKET',
              color: brandColor,
              onTap: () async {
                context.pop();
                if (item.imagePath != null) {
                  await exportService.shareTicketImage(File(item.imagePath!), 'Ticket de ${item.name}');
                }
              },
            ),
            
            const SizedBox(height: 20),
            
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'CANCELAR',
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ExportOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 15),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, color: color.withValues(alpha: 0.3), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
