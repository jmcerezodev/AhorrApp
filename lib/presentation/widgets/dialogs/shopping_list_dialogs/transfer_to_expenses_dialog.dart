import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransferToExpensesDialog extends StatelessWidget {
  const TransferToExpensesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shoppingCubit = context.read<ShoppingListCubit>();
    final historyCubit = context.read<HistoryCubit>();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      title: const Column(
        children: [
          Icon(Icons.receipt_long_rounded, color: Colors.orange, size: 40),
          SizedBox(height: 10),
          Text(
            'Transferir a Gastos',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
        ],
      ),
      content: const Text(
        '¿Cómo quieres guardar los productos de la cesta en tu historial de gastos?',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, color: Colors.grey),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowButtonSpacing: 10,
      actions: [
        _DialogButton(
          label: 'TODO EN UN PACK',
          icon: Icons.inventory_2_rounded,
          onPressed: () {
            Navigator.pop(context);
            shoppingCubit.transferToExpenses(asPack: true, historyCubit: historyCubit);
          },
        ),
        _DialogButton(
          label: 'PRODUCTO A PRODUCTO',
          icon: Icons.list_alt_rounded,
          onPressed: () {
            Navigator.pop(context);
            shoppingCubit.transferToExpenses(asPack: false, historyCubit: historyCubit);
          },
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'CANCELAR',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _DialogButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange.withValues(alpha: 0.1),
          foregroundColor: Colors.orange,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
          side: const BorderSide(color: Colors.orange, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
