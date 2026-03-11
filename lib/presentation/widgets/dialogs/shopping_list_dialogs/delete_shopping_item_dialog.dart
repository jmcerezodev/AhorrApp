import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_list_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DeleteShoppingItemDialog extends StatelessWidget {
  final String itemId;
  final String itemName;

  const DeleteShoppingItemDialog({
    super.key,
    required this.itemId,
    required this.itemName,
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
            icon: Icons.delete_outline_rounded, 
            color: Colors.red.shade400, 
            title: '¿ELIMINAR PRODUCTO?',
            circularBackground: true,
            iconSize: 32,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 15),
          
          Text.rich(
            TextSpan(
              style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withValues(alpha: 0.5), height: 1.5),
              children: [
                const TextSpan(text: 'Estás a punto de borrar '),
                TextSpan(text: '"$itemName"', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                const TextSpan(text: ' de tu lista. Esta acción '),
                const TextSpan(text: 'no se puede deshacer.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
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
                    context.read<ShoppingListCubit>().deleteItem(itemId);
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
