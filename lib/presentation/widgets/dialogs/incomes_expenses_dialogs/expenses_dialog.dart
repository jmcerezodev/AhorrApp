import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/core/shared_preferences/preferences.dart';
import 'package:ahorrapp/data/appwrite/appwrite_repository.dart';
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

  double _calculateCurrentBalance(List<Map<String, dynamic>> history) {
    double total = 0;
    for (var item in history) {
      final double money = (item['money'] as num).toDouble();
      if (item['isIncome'] == true) {
        total += money;
      } else {
        total -= money;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final date = Date();
    final AppwriteRepository appwriteRepo = AppwriteRepository();
    final expensesCubit = context.watch<ExpensesCubit>();
    final historyList = context.watch<HistoryCubit>().state.historyList;
    final double currentBalance = _calculateCurrentBalance(historyList);

    final double typedAmount = double.tryParse(expensesCubit.state.expenseMoney.value.replaceAll(',', '.')) ?? 0;
    final bool hasEnoughBalance = typedAmount <= currentBalance;

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
                  child: Icon(Icons.trending_down_rounded, color: Colors.orange.shade700, size: 24),
                ),
                const SizedBox(width: 15),
                const Text(
                  'NUEVO GASTO',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.blueGrey,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Saldo Disponible (Badge Informativo)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Saldo disponible: ', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  Text('${currentBalance.toStringAsFixed(2)}€', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
                    onPressed: (expensesCubit.state.isValid && hasEnoughBalance && typedAmount > 0) 
                    ? () async {
                      expensesCubit.onSubmit();
                      await appwriteRepo.addHistory(
                        userId: Preferences.uId,
                        name: expensesCubit.state.expenseName.value,
                        money: typedAmount,
                        isIncome: false,
                        currentDate: date.currentDate(),
                        currentHour: date.currentHour(),
                        month: date.monthNames(),
                        year: int.parse(date.year()),
                      );
                      if (context.mounted) {
                        await context.read<HistoryCubit>().loadHistory();
                        expensesCubit.resetCubit();
                        context.pop();
                      }
                    }
                    : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('GUARDAR', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
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
