import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
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
  final List<Map<String, dynamic>> _categories = [
    {'id': 'general', 'icon': Icons.receipt_long_rounded, 'name': 'General'},
    {'id': 'hogar', 'icon': Icons.home_work_rounded, 'name': 'Hogar'},
    {'id': 'suscripción', 'icon': Icons.subscriptions_rounded, 'name': 'Suscripción'},
    {'id': 'salud', 'icon': Icons.favorite_rounded, 'name': 'Salud'},
    {'id': 'transporte', 'icon': Icons.directions_car_rounded, 'name': 'Transporte'},
    {'id': 'ocio', 'icon': Icons.sports_esports_rounded, 'name': 'Ocio'},
  ];

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
    final errorColor = Colors.red.shade400;

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
            border: Border.all(color: errorColor.withValues(alpha: isDark ? 0.2 : 0.4), width: 1.5)
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppDialogs.dialogRowHeader(
                icon: Icons.trending_down_rounded,
                title: 'NUEVO GASTO',
                color: errorColor,
                colorScheme: colorScheme,
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
                enabled: expensesCubit.state.status != ExpensesStatus.posting,
                autoFocus: true,
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
                enabled: expensesCubit.state.status != ExpensesStatus.posting,
                autoFocus: false,
              ),
              const SizedBox(height: 25),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Categoría',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: expensesCubit.state.category,
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(15),
                    items: _categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat['id'],
                        child: Row(
                          children: [
                            Icon(cat['icon'], size: 16, color: errorColor),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                cat['name'],
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => expensesCubit.categoryChanged(val ?? 'general'),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: expensesCubit.state.status == ExpensesStatus.posting 
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
                    child: AppDialogs.dialogPrimaryButton(
                      text: 'GUARDAR',
                      color: Colors.orange, // Mantenemos el naranja corporativo en el botón
                      isLoading: expensesCubit.state.status == ExpensesStatus.posting,
                      onPressed: (expensesCubit.state.isValid && hasEnoughBalance && typedAmount > 0 && expensesCubit.state.status != ExpensesStatus.posting) 
                      ? () async {
                        await expensesCubit.saveExpense(historyCubit);
                        if (context.mounted && expensesCubit.state.status == ExpensesStatus.success) {
                          context.pop();
                        }
                      }
                      : null,
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
