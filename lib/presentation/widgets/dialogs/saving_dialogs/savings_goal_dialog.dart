import 'package:ahorrapp/presentation/bloc/savings_cubit/savings_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:ahorrapp/presentation/widgets/inputs/inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SavingsGoalDialog extends StatefulWidget {
  const SavingsGoalDialog({super.key});

  @override
  State<SavingsGoalDialog> createState() => _SavingsGoalDialogState();
}

class _SavingsGoalDialogState extends State<SavingsGoalDialog> {
  String goalValue = '';
  bool isValid = false;

  @override
  Widget build(BuildContext context) {
    final savingsCubit = context.read<SavingsCubit>();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomDialogWrapper(
      borderColor: colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.4),
      horizontalInsetPadding: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDialogs.dialogRowHeader(
            icon: Icons.flag_rounded, 
            title: 'ESTABLECER META', 
            color: colorScheme.primary, 
            colorScheme: colorScheme
          ),
          const SizedBox(height: 30),

          CustomInputTextWidget(
            label: '¿Cuál es tu objetivo de ahorro?',
            hintText: '0.00',
            onChanged: (value) {
              setState(() {
                goalValue = value;
                isValid = double.tryParse(value.replaceAll(',', '.')) != null;
              });
            },
            autoFocus: true,
            textInputType: const TextInputType.numberWithOptions(decimal: true),
          ),
          
          const SizedBox(height: 30),

          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
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
                  text: 'GUARDAR', 
                  color: colorScheme.primary,
                  onPressed: isValid ? () {
                    final double? goal = double.tryParse(goalValue.replaceAll(',', '.'));
                    if (goal != null) {
                      savingsCubit.setGoal(goal);
                      Navigator.of(context).pop();
                    }
                  } : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
