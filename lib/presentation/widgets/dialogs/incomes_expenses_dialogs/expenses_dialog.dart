import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
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

    return CustomDialogWrapper(
      borderColor: errorColor.withValues(alpha: isDark ? 0.2 : 0.4),
      horizontalInsetPadding: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDialogs.dialogRowHeader(
            icon: Icons.trending_down_rounded,
            title: 'Nuevo Gasto',
            color: errorColor,
            colorScheme: colorScheme,
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
                Text('SALDO DISPONIBLE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: colorScheme.onSurface.withValues(alpha: 0.4), letterSpacing: 1)),
                const SizedBox(height: 5),
                Text('${HumanizeNumbers().format(totalBalance)}€', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: colorScheme.onSurface)),
              ],
            ),
          ),
          const SizedBox(height: 25),

          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomInputTextWidget(
                    label: 'CONCEPTO DEL GASTO',
                    hintText: 'Ej. Supermercado',
                    onChanged: expensesCubit.expenseNameChanged,
                    errorText: expensesCubit.state.expenseName.isPure ? null : expensesCubit.state.expenseName.errorMessage,
                    textInputType: TextInputType.name,
                    enabled: expensesCubit.state.status != ExpensesStatus.posting,
                    autoFocus: true,
                  ),
                  const SizedBox(height: 15),
                  CustomInputTextWidget(
                    label: 'IMPORTE',
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
            
                  Text('CATEGORÍA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: colorScheme.onSurface.withValues(alpha: 0.4), letterSpacing: 1)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade300),
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
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    cat['name'],
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
                  text: 'GUARDAR',
                  color: Colors.orange,
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
    );
  }
}
