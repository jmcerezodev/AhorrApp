import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_templates_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DeleteFavoriteDialog extends StatelessWidget {
  final String templateId;
  final String productName;

  const DeleteFavoriteDialog({
    super.key,
    required this.templateId,
    required this.productName,
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
            icon: Icons.favorite_border_rounded, 
            color: Colors.red.shade400, 
            title: '¿QUITAR DE FAVORITOS?',
            circularBackground: true,
            iconSize: 32,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 15),
          
          Text.rich(
            TextSpan(
              style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withValues(alpha: 0.5), height: 1.5),
              children: [
                const TextSpan(text: 'Estás a punto de quitar '),
                TextSpan(text: '"$productName"', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                const TextSpan(text: ' de tus favoritos. Podrás volver a añadirlo en cualquier momento.'),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => context.pop(false),
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                  child: Text(
                    'CANCELAR', 
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.4), 
                      fontWeight: FontWeight.bold, 
                      letterSpacing: 1
                    )
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: AppDialogs.dialogPrimaryButton(
                  text: 'ELIMINAR', 
                  color: Colors.red.shade400,
                  onPressed: () {
                    context.read<ShoppingTemplatesCubit>().deleteTemplate(templateId);
                    context.pop(true);
                  }, 
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
