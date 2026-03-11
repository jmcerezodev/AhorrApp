import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_list_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DeleteBoughtItemsDialog extends StatelessWidget {
  const DeleteBoughtItemsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomDialogWrapper(
      borderColor: Colors.orange.withValues(alpha: isDark ? 0.2 : 0.4),
      horizontalInsetPadding: 30,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDialogs.dialogHeader(
            icon: Icons.shopping_basket_outlined, 
            color: Colors.orange, 
            title: '¿VACIAR CESTA?',
            circularBackground: true,
            iconSize: 32,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 15),
          
          Text.rich(
            TextSpan(
              style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withValues(alpha: 0.5), height: 1.5),
              children: [
                const TextSpan(text: 'Se van a eliminar '),
                const TextSpan(text: 'todos los productos', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                const TextSpan(text: ' marcados en la cesta. Esta acción '),
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
                  onPressed: () => context.pop(),
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
                  text: 'VACIAR', 
                  color: Colors.orange,
                  onPressed: () {
                    context.read<ShoppingListCubit>().clearBoughtItems();
                    context.pop();
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
