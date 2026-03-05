import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_list_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeleteBoughtItemsDialog extends StatelessWidget {
  const DeleteBoughtItemsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      title: const Column(
        children: [
          Icon(Icons.delete_sweep_rounded, color: Colors.orange, size: 40),
          SizedBox(height: 10),
          Text(
            'Vaciar Cesta',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
        ],
      ),
      content: const Text(
        'Se eliminarán todos los productos marcados en la cesta. Esta acción no se puede deshacer.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, color: Colors.grey),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'CANCELAR',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<ShoppingListCubit>().clearBoughtItems();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: const Text('VACIAR'),
        ),
      ],
    );
  }
}
