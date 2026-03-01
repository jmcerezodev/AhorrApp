import 'package:ahorrapp/presentation/bloc/cubits.dart';
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

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.orange.shade700.withValues(alpha: isDark ? 0.3 : 0.5), 
              width: 1.5
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade700.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.outbox_rounded, color: Colors.orange.shade700, size: 24),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    'RETIRAR AHORRO',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
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
                    child: ElevatedButton(
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

                          if (context.mounted && context.read<SavingsCubit>().state.status == SavingsStatus.success) {
                            context.pop();
                          }
                        }
                      : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('RETIRAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
