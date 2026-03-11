import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/presentation/bloc/history_cubit/history_cubit.dart';
import 'package:ahorrapp/presentation/bloc/savings_cubit/savings_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';

class SavingsDeleteDialog extends StatelessWidget {
  const SavingsDeleteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final humanizeNumbers = HumanizeNumbers();
    final savingsCubit = context.watch<SavingsCubit>();
    final savingsState = savingsCubit.state;
    final totalSaving = humanizeNumbers.number(savingsState.savingTotal);
    
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isLoading = savingsState.status == SavingsStatus.loading;

    return BlocListener<SavingsCubit, SavingsCubitState>(
      listener: (context, state) {
        if (state.status == SavingsStatus.success) {
          context.pop();
        }
      },
      child: CustomDialogWrapper(
        borderColor: Colors.red.shade400.withValues(alpha: isDark ? 0.2 : 0.4),
        horizontalInsetPadding: 30,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppDialogs.dialogHeader(
              icon: Icons.warning_amber_rounded, 
              color: Colors.red.shade400, 
              title: '¿Vaciar Ahorros?',
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 20),
            
            AppDialogs.dialogMessage(
              'Tienes $totalSaving€ ahorrados. Al confirmar, el contador volverá a cero pero tus registros se mantendrán en el historial.', 
              colorScheme
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
                    onPressed: isLoading ? null : () => context.pop(), 
                    colorScheme: colorScheme
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: AppDialogs.dialogPrimaryButton(
                    text: 'VACIAR',
                    color: Colors.red.shade400,
                    isLoading: isLoading,
                    onPressed: isLoading 
                      ? null
                      : () async {
                          final historyCubit = context.read<HistoryCubit>();
                          await context.read<SavingsCubit>().emptySavings(historyCubit);
                        },
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
