import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DeleteSavingItemDialog extends StatelessWidget {
  final String savingId;
  const DeleteSavingItemDialog({super.key, required this.savingId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final historyCubit = context.watch<HistoryCubit>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Map<String, dynamic>? item;
    for (final s in historyCubit.state.historyList) {
      if (s['id'] == savingId) {
        item = s;
        break;
      }
    }
    
    if (item == null) return const SizedBox();
    
    final double amount = (item['money'] as num).toDouble();
    final bool isWithdrawal = amount < 0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: colorScheme.surface, 
          borderRadius: BorderRadius.circular(30), 
          border: Border.all(color: Colors.red.shade400.withValues(alpha: isDark ? 0.2 : 0.4), width: 1.5)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12), 
              decoration: BoxDecoration(color: Colors.red.shade400.withValues(alpha: 0.1), shape: BoxShape.circle), 
              child: Icon(isWithdrawal ? Icons.undo_rounded : Icons.delete_sweep_rounded, color: Colors.red.shade400, size: 32)
            ),
            const SizedBox(height: 20),
            Text(
              isWithdrawal ? '¿ELIMINAR RETIRADA?' : '¿ELIMINAR APORTACIÓN?', 
              textAlign: TextAlign.center, 
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.5)
            ),
            const SizedBox(height: 15),
            Text(
              isWithdrawal 
                ? 'Al eliminar esta retirada, el dinero se sumará de nuevo a tus ahorros totales.' 
                : 'Esta aportación se restará de tus ahorros totales y se borrará del historial.', 
              textAlign: TextAlign.center, 
              style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withValues(alpha: 0.5), height: 1.5)
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => context.pop(), 
                    child: Text('CANCELAR', style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.4), fontWeight: FontWeight.bold, letterSpacing: 1))
                  )
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await context.read<SavingsCubit>().removeContribution(savingId);
                      
                      if (context.mounted) {
                        await historyCubit.deleteMovementLocally(
                          savingId, 
                          item!['month'] ?? '', 
                          item['year'] ?? 0, 
                          amount, 
                          'saving'
                        );
                        context.pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400, 
                      foregroundColor: Colors.white, 
                      padding: const EdgeInsets.symmetric(vertical: 15), 
                      elevation: 0, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                    ),
                    child: const Text('ELIMINAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
