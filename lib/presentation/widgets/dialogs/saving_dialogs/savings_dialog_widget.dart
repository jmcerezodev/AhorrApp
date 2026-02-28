import 'package:ahorrapp/presentation/bloc/savings_cubit/savings_cubit.dart';
import 'package:ahorrapp/presentation/widgets/inputs/inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SavingsDialog extends StatefulWidget {
  const SavingsDialog({super.key});

  @override
  State<SavingsDialog> createState() => _SavingsDialogState();
}

class _SavingsDialogState extends State<SavingsDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavingsCubit>().resetCubit();
    });
  }

  @override
  Widget build(BuildContext context) {
    final savingsCubit = context.watch<SavingsCubit>();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.orange.shade100, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono y Título
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.savings_outlined, color: Colors.orange.shade700, size: 24),
                ),
                const SizedBox(width: 15),
                const Text(
                  'GESTIONAR AHORRO',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.blueGrey,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            CustomInputTextWidget(
              label: 'Cantidad a ahorrar',
              hintText: '0.00',
              onChanged: savingsCubit.savingChanged,
              errorText: savingsCubit.state.saving.isPure ? null : savingsCubit.state.saving.errorMessage,
              textInputType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => context.pop(),
                    style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                    child: Text('CANCELAR', style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (savingsCubit.state.saving.isValid)
                    ? () {
                        savingsCubit.onSubmit();
                        savingsCubit.resetCubit();
                        context.pop();
                      }
                    : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('AHORRAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
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
