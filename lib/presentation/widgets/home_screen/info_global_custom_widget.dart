import 'package:animate_do/animate_do.dart';
import 'package:ahorrapp/core/filter_lists/filter_lists.dart';
import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/saving_dialogs/savings_goal_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InfoGlogalWidget extends StatelessWidget {
  const InfoGlogalWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final filterLists = FilterLists();
    final savingsState = context.watch<SavingsCubit>().state;
    final historyCubit = context.watch<HistoryCubit>();
    final humanizeNumbers = HumanizeNumbers();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final double totalMoneyResult = filterLists.calculateTotalMoney(context, historyCubit);

    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              // BALANCE TOTAL
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BALANCE TOTAL',
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${humanizeNumbers.number(totalMoneyResult)}€',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              // TARJETA DE AHORROS Y META
              Expanded(
                flex: 2,
                child: _SavingGoalCard(
                  money: savingsState.savingTotal,
                  goal: savingsState.savingGoal,
                  progress: savingsState.progress,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavingGoalCard extends StatelessWidget {
  final double money;
  final double goal;
  final double progress;

  const _SavingGoalCard({
    required this.money,
    required this.goal,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final humanizeNumbers = HumanizeNumbers();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Determinar si se ha alcanzado la meta
    final bool goalReached = goal > 0 && progress >= 1.0;
    
    // Colores dinámicos basados en el éxito
    final Color accentColor = goalReached ? Colors.green.shade400 : colorScheme.primary;
    final Color bgColor = goalReached 
        ? Colors.green.shade400.withValues(alpha: isDark ? 0.15 : 0.05)
        : accentColor.withValues(alpha: 0.05);

    return InkWell(
      onTap: () => showDialog(
        barrierDismissible: false,
        context: context,
        builder: (dialogContext) => const SavingsDialog(),
      ),
      onLongPress: () => showDialog(
        barrierDismissible: false,
        context: context,
        builder: (dialogContext) => const SavingsGoalDialog(),
      ),
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.2), 
            width: 1.2
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (goalReached) 
                  const Icon(Icons.stars_rounded, color: Colors.green, size: 10),
                const SizedBox(width: 4),
                Text(
                  goalReached ? '¡META LOGRADA!' : 'MIS AHORROS',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${humanizeNumbers.number(money)}€',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Barra de progreso y meta
            if (goal > 0) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: accentColor.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                child: Text(
                  goalReached ? 'Objetivo: ${humanizeNumbers.number(goal)}€' : 'Meta: ${humanizeNumbers.number(goal)}€',
                  style: TextStyle(
                    fontSize: 7, 
                    color: goalReached ? Colors.green.shade700 : colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w800
                  ),
                ),
              ),
            ] else 
              Text(
                'Sin meta fija',
                style: TextStyle(
                  fontSize: 7, 
                  color: colorScheme.onSurface.withValues(alpha: 0.3), 
                  fontStyle: FontStyle.italic
                ),
              ),
          ],
        ),
      ),
    );
  }
}
