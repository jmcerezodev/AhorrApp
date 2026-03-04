import 'package:ahorrapp/presentation/bloc/cubits.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavingsCubit>().resetCubit();
    });
  }

  @override
  Widget build(BuildContext context) {
    final savingsCubit = context.watch<SavingsCubit>();
    final historyCubit = context.read<HistoryCubit>();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isLoading = savingsCubit.state.status == SavingsStatus.loading;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocListener<SavingsCubit, SavingsCubitState>(
      listener: (context, state) {
        if (state.status == SavingsStatus.success) {
          context.pop();
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Container(
          // Limitamos el tamaño máximo para evitar overflows con el teclado
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.4), 
              width: 1.5
            ),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.fromLTRB(25, 25, 25, bottomInset > 0 ? 10 : 25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.savings_outlined, color: colorScheme.primary, size: 24),
                          ),
                          const SizedBox(width: 15),
                          Text(
                            'GESTIÓN AHORROS',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface.withValues(alpha: 0.7),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: isLoading ? null : () {
                          context.pop();
                          showDialog(
                            context: context,
                            builder: (context) => const SavingsDeleteDialog(),
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
                        child: ElevatedButton(
                          onPressed: (savingsCubit.state.isValid && !isLoading)
                          ? () async {
                              await context.read<SavingsCubit>().addSaving(historyCubit);
                            }
                          : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: isLoading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('AHORRAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
      
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: isLoading ? null : () {
                            context.pop();
                            showDialog(
                              context: context,
                              builder: (context) => const SavingsWithdrawDialog(),
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
          ),
        ),
      ),
    );
  }
}
