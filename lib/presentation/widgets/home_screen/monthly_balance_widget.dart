import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MonthlyBalanceWidget extends StatelessWidget {
  const MonthlyBalanceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final historyList = context.watch<HistoryCubit>().state.historyList;
    final dateState = context.watch<DateCubit>().state;
    final humanizeNumbers = HumanizeNumbers();

    double monthlyTotal = 0;
    for (var item in historyList) {
      if (item['year'] == dateState.year && item['month'] == dateState.month) {
        final double money = (item['money'] as num).toDouble();
        final String type = item['type'] ?? '';
        if (type == 'income') monthlyTotal += money;
        else if (type == 'expense') monthlyTotal -= money;
      }
    }

    final bool isPositive = monthlyTotal >= 0;
    final Color baseColor = isPositive ? Colors.green : Colors.red;
    final Color textColor = isPositive ? Colors.green.shade700 : Colors.red.shade700;

    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: baseColor.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'BALANCE MES',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: textColor,
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
                  color: textColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
