import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/saving_dialogs/savings_empty_dialog_widget.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/saving_dialogs/savings_withdraw_dialog.dart';
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
    // REVISIÓN: No reseteamos el Cubit completo, solo el formulario si es necesario.
    // Pero para evitar el borrado visual, quitamos el resetCubit() que causaba el problema.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavingsCubit>().resetForm();
    });
  }

  @override
  Widget build(BuildContext context) {
    final savingsCubit = context.watch<SavingsCubit>();
    final historyCubit = context.read<HistoryCubit>();
    final colorScheme = Theme.of(context).colorScheme;
    final bool isLoading = savingsCubit.state.status == SavingsStatus.loading;

    return BlocListener<SavingsCubit, SavingsCubitState>(
      listener: (context, state) {
        if (state.status == SavingsStatus.success) {
          // Si cerramos el diálogo tras éxito, el loadSavings ya se llamó en el Cubit
          context.pop();
        }
      },
      child: CustomDialogWrapper(
        horizontalInsetPadding: 20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AppDialogs.dialogRowHeader(
                    icon: Icons.savings_outlined, 
                    title: 'GESTIÓN AHORROS', 
                    color: colorScheme.primary, 
                    colorScheme: colorScheme
                  ),
                ),
                IconButton(
                  onPressed: isLoading ? null : () {
                    context.pop();
                    AppDialogs.showCustomDialog(
                      context: context,
                      builder: const SavingsDeleteDialog(),
                    );
                  },
                  icon: Icon(Icons.delete_sweep_rounded, color: Colors.red.shade300, size: 22),
                ),
              ],
            ),
            const SizedBox(height: 30),

            CustomInputTextWidget(
              label: 'Cantidad a añadir',
              hintText: '0.00',
              onChanged: savingsCubit.savingChanged,
              errorText: savingsCubit.state.saving.isPure ? null : savingsCubit.state.saving.errorMessage,
              textInputType: const TextInputType.numberWithOptions(decimal: true),
              enabled: !isLoading,
            ),
            const SizedBox(height: 30),

            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: AppDialogs.dialogPrimaryButton(
                    text: 'AHORRAR',
                    color: colorScheme.primary,
                    isLoading: isLoading,
                    onPressed: (savingsCubit.state.isValid && !isLoading)
                    ? () async {
                        await context.read<SavingsCubit>().addSaving(historyCubit);
                      }
                    : null,
                  ),
                ),
                
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: isLoading ? null : () {
                      context.pop();
                      AppDialogs.showCustomDialog(
                        context: context,
                        builder: const SavingsWithdrawDialog(),
                      );
                    },
                    icon: const Icon(Icons.outbox_rounded, size: 18),
                    label: const Text('RETIRAR DINERO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
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
