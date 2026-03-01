import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MonthlyBalanceWidget extends StatelessWidget {
  const MonthlyBalanceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final historyList = context.watch<HistoryCubit>().state.historyList;
    final dateState = context.watch<DateCubit>().state;
    final humanizeNumbers = HumanizeNumbers();

    // Calcular balance del mes actual seleccionado (Solo Ingresos y Gastos)
    double monthlyTotal = 0;
    for (var item in historyList) {
      if (item['year'] == dateState.year && item['month'] == dateState.month) {
        final double money = (item['money'] as num).toDouble();
        final String type = item['type'] ?? '';

        if (type == 'income') {
          monthlyTotal += money;
        } else if (type == 'expense') {
          monthlyTotal -= money;
        }
        // Los ahorros (type == 'saving') se ignoran para el balance
      }
    }

    final bool isPositive = monthlyTotal >= 0;

    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: isPositive 
          ? Colors.green.shade400.withValues(alpha: isDark ? 0.15 : 0.1)
          : Colors.red.shade400.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPositive 
            ? Colors.green.shade400.withValues(alpha: 0.3)
            : Colors.red.shade400.withValues(alpha: 0.3),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'BALANCE MES',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
              letterSpacing: 0.5,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '${isPositive ? "+" : ""}${humanizeNumbers.number(monthlyTotal)}€',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
