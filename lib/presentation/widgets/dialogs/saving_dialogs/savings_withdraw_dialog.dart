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
        borderColor: Colors.orange.withValues(alpha: isDark ? 0.2 : 0.4),
        horizontalInsetPadding: 20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppDialogs.dialogRowHeader(
              icon: Icons.outbox_rounded, 
              title: 'Retirar Ahorro', 
              color: Colors.orange, 
              colorScheme: colorScheme
            ),
            const SizedBox(height: 25),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text('AHORROS DISPONIBLES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: colorScheme.onSurface.withValues(alpha: 0.4), letterSpacing: 1)),
                  const SizedBox(height: 5),
                  Text('${savingsTotal.toStringAsFixed(2)}€', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: colorScheme.onSurface)),
                ],
              ),
            ),
      
            const SizedBox(height: 25),
      
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomInputTextWidget(
                      controller: _amountController,
                      label: 'CANTIDAD A RETIRAR',
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
                      label: '¿EN QUÉ LO VAS A GASTAR? (OPCIONAL)',
                      hintText: 'Ej. Reparación coche, Capricho...',
                      enabled: !isLoading,
                      autoFocus: false,
                      textInputType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
      
            Row(
              children: [
                Expanded(
                  child: AppDialogs.dialogSecondaryButton(
                    text: 'CANCELAR', 
                    onPressed: () => context.pop(), 
                    colorScheme: colorScheme
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: AppDialogs.dialogPrimaryButton(
                    text: 'RETIRAR',
                    color: Colors.orange,
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
                    : null,
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
