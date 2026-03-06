import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:ahorrapp/presentation/widgets/inputs/inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SavingsWithdrawDialog extends StatefulWidget {
  const SavingsWithdrawDialog({super.key});

  @override
  State<SavingsWithdrawDialog> createState() => _SavingsWithdrawDialogState();
}

class _SavingsWithdrawDialogState extends State<SavingsWithdrawDialog> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _conceptController = TextEditingController();
  String _amountValue = '';
  bool _isValid = false;

  @override
  void dispose() {
    _amountController.dispose();
    _conceptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final savingsCubit = context.watch<SavingsCubit>();
    final historyCubit = context.read<HistoryCubit>();
    final savingsTotal = savingsCubit.state.savingTotal;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isLoading = savingsCubit.state.status == SavingsStatus.loading;

    return BlocListener<SavingsCubit, SavingsCubitState>(
      listener: (context, state) {
        if (state.status == SavingsStatus.success) {
          context.pop();
        }
      },
      child: CustomDialogWrapper(
        borderColor: Colors.orange.shade700.withValues(alpha: isDark ? 0.3 : 0.5),
        horizontalInsetPadding: 20,
        wrapInScrollView: true, // ADN Original: permite scroll de toda la tarjeta
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppDialogs.dialogRowHeader(
              icon: Icons.outbox_rounded, 
              title: 'RETIRAR AHORRO', 
              color: Colors.orange.shade700, 
              colorScheme: colorScheme
            ),
            const SizedBox(height: 20),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text('Ahorros disponibles', style: TextStyle(fontSize: 10, color: colorScheme.onSurface.withValues(alpha: 0.5))),
                  Text('${savingsTotal.toStringAsFixed(2)}€', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: colorScheme.onSurface)),
                ],
              ),
            ),
      
            const SizedBox(height: 25),
      
            CustomInputTextWidget(
              controller: _amountController,
              label: 'Cantidad a retirar',
              hintText: '0.00',
              enabled: !isLoading,
              onChanged: (val) {
                setState(() {
                  _amountValue = val;
                  final double? amount = double.tryParse(val.replaceAll(',', '.'));
                  _isValid = amount != null && amount > 0 && amount <= savingsTotal;
                });
              },
              textInputType: const TextInputType.numberWithOptions(decimal: true),
            ),
            
            const SizedBox(height: 15),
      
            CustomInputTextWidget(
              controller: _conceptController,
              label: '¿En qué lo vas a gastar? (opcional)',
              hintText: 'Ej. Reparación coche, Capricho...',
              enabled: !isLoading,
              autoFocus: false,
              textInputType: TextInputType.text,
              textCapitalization: TextCapitalization.sentences,
            ),
            
            const SizedBox(height: 30),
      
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: isLoading ? null : () => context.pop(),
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
                    text: 'RETIRAR',
                    color: Colors.orange.shade700,
                    isLoading: isLoading,
                    onPressed: (_isValid && !isLoading)
                    ? () async {
                        final double amount = double.parse(_amountValue.replaceAll(',', '.'));
                        final String concept = _conceptController.text.trim().isEmpty 
                            ? 'Retirada de ahorros' 
                            : _conceptController.text.trim();

                        await context.read<SavingsCubit>().addSaving(
                          historyCubit,
                          customAmount: -amount,
                          customName: concept,
                        );
                      }
                    : null, // Corregido: null para estado deshabilitado visual
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
