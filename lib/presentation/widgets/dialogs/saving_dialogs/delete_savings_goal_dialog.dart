import 'package:ahorrapp/presentation/bloc/savings_cubit/savings_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DeleteSavingsGoalDialog extends StatelessWidget {
  const DeleteSavingsGoalDialog({super.key});

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
            icon: Icons.flag_outlined, 
            color: Colors.red.shade400, 
            title: '¿ELIMINAR META ACTUAL?',
            circularBackground: true,
            iconSize: 32,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 15),
          
          Text.rich(
            TextSpan(
              style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withValues(alpha: 0.5), height: 1.5),
              children: [
                const TextSpan(text: 'Tienes una '),
                const TextSpan(text: 'meta de ahorro', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                const TextSpan(text: ' activa. Para establecer una nueva, primero debes '),
                const TextSpan(text: 'eliminar la actual', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                const TextSpan(text: '.'),
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
                  text: 'ELIMINAR', 
                  color: Colors.red.shade400,
                  onPressed: () {
                    // Establecemos la meta a 0 para eliminarla
                    context.read<SavingsCubit>().setGoal(0);
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
