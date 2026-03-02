import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DeleteRecurrentExpenseDialog extends StatelessWidget {
  final String expenseId;
  final String expenseName;

  const DeleteRecurrentExpenseDialog({
    super.key,
    required this.expenseId,
    required this.expenseName,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red),
          SizedBox(width: 10),
          Text('¿Eliminar gasto fijo?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      content: RichText(
        text: TextSpan(
          style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
          children: [
            const TextSpan(text: '¿Estás seguro de que deseas eliminar '),
            TextSpan(text: expenseName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
            const TextSpan(text: '? Esta acción no se puede deshacer.'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(false),
          child: Text('CANCELAR', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.bold)),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<RecurrentExpensesCubit>().deleteExpense(expenseId);
            context.pop(true);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('ELIMINAR', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
