import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/presentation/bloc/history_cubit/history_cubit.dart';
import 'package:ahorrapp/presentation/bloc/savings_cubit/savings_cubit.dart';

class SavingsDeleteDialog extends StatelessWidget {
  const SavingsDeleteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final humanizeNumbers = HumanizeNumbers();
    
    // Obtenemos los estados usando watch para reactividad
    final savingsState = context.watch<SavingsCubit>().state;
    final totalSaving = humanizeNumbers.number(savingsState.savingTotal);
    
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
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
              child: Icon(Icons.warning_amber_rounded, color: colorScheme.primary, size: 32),
            ),
            const SizedBox(height: 20),
            
            Text(
              '¿VACIAR AHORROS?',
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
              'Tienes $totalSaving€ ahorrados. Al confirmar, el contador volverá a cero pero tus registros se mantendrán en el historial como "gastados".',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                height: 1.5,
              ),
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
                  child: ElevatedButton(
                    onPressed: () async {
                      // Referencias directas para evitar errores de tipo en el editor
                      final historyCubit = BlocProvider.of<HistoryCubit>(context);
                      final savingsCubit = BlocProvider.of<SavingsCubit>(context);
                      
                      await savingsCubit.emptySavings(historyCubit);
                      
                      if (context.mounted) {
                        context.pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('VACIAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
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
