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
            title: '¿Eliminar Producto?',
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 20),
          
          AppDialogs.dialogMessage(
            'Estás a punto de borrar de tu lista el producto:',
            colorScheme,
          ),
          const SizedBox(height: 10),
          Text(
            '"$itemName"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 15),
          AppDialogs.dialogMessage(
            'Esta acción no se puede deshacer.',
            colorScheme,
            customColor: Colors.red.shade400.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 30),

          Row(
            children: [
              Expanded(
                child: AppDialogs.dialogSecondaryButton(
                  text: 'CANCELAR', 
                  onPressed: () => context.pop(false),
                  colorScheme: colorScheme,
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
