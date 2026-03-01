import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/inputs/inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ExpensesDialog extends StatefulWidget {
  const ExpensesDialog({super.key});

  @override
  State<ExpensesDialog> createState() => _ExpensesDialogState();
}

class _ExpensesDialogState extends State<ExpensesDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpensesCubit>().resetCubit();
    });
  }

  @override
  Widget build(BuildContext context) {
    final expensesCubit = context.watch<ExpensesCubit>();
    final historyCubit = context.read<HistoryCubit>();
    final double totalBalance = context.watch<TotalMoneyCubit>().state.totalMoney;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final double typedAmount = double.tryParse(expensesCubit.state.expenseMoney.value.replaceAll(',', '.')) ?? 0;
    final bool hasEnoughBalance = typedAmount <= totalBalance;

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
              color: colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.4), 
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
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.trending_down_rounded, color: colorScheme.primary, size: 24),
                  ),
                  const SizedBox(width: 15),
                  Text(
                    'NUEVO GASTO',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Saldo disponible: ', 
                      style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12)
                    ),
                    Text(
                      '${totalBalance.toStringAsFixed(2)}€', 
                      style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 13)
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              CustomInputTextWidget(
                label: 'Concepto del gasto',
                hintText: 'Ej. Supermercado',
                onChanged: expensesCubit.expenseNameChanged,
                errorText: expensesCubit.state.expenseName.isPure ? null : expensesCubit.state.expenseName.errorMessage,
                textInputType: TextInputType.name,
                enabled: expensesCubit.state.formStatus != FormStatusExpenses.validating,
              ),
              const SizedBox(height: 15),
              CustomInputTextWidget(
                label: 'Importe',
                hintText: '0.00',
                onChanged: expensesCubit.expenseMoneyChanged,
                errorText: (typedAmount > 0 && !hasEnoughBalance) 
                    ? 'Excede el saldo disponible' 
                    : (expensesCubit.state.expenseMoney.isPure ? null : expensesCubit.state.expenseMoney.errorMessage),
                textInputType: const TextInputType.numberWithOptions(decimal: true),
                enabled: expensesCubit.state.formStatus != FormStatusExpenses.validating,
              ),
              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: expensesCubit.state.formStatus == FormStatusExpenses.validating 
                        ? null 
                        : () => context.pop(),
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
                      onPressed: (expensesCubit.state.isValid && hasEnoughBalance && typedAmount > 0 && expensesCubit.state.formStatus != FormStatusExpenses.validating) 
                      ? () async {
                        await expensesCubit.saveExpense(historyCubit);
                        if (context.mounted && expensesCubit.state.formStatus == FormStatusExpenses.valid) {
                          context.pop();
                        }
                      }
                      : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: expensesCubit.state.formStatus == FormStatusExpenses.validating
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('GUARDAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
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
