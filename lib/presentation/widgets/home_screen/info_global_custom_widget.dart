import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/saving_dialogs/delete_savings_goal_dialog.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/saving_dialogs/savings_goal_dialog.dart';
import 'package:ahorrapp/presentation/widgets/widgets.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InfoGlogalWidget extends StatelessWidget {
  const InfoGlogalWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final historyState = context.watch<HistoryCubit>().state;
    final totalMoneyState = context.watch<TotalMoneyCubit>().state;
    final savingsState = context.watch<SavingsCubit>().state;
    final themeState = context.watch<ThemeCubit>().state;
    final humanizeNumbers = HumanizeNumbers();
    final colorScheme = Theme.of(context).colorScheme;
    
    final bool isLoading = historyState.status == HistoryStatus.loading || historyState.isSyncing;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final bool isGoalMet = savingsState.progress >= 1.0 && savingsState.savingGoal > 0;

    final double displayedBalance = totalMoneyState.isSavingsIncluded 
        ? (totalMoneyState.totalMoney + savingsState.savingTotal)
        : totalMoneyState.totalMoney;

    final isPrivacyActive = themeState.isPrivacyModeActive;

    return FadeInDown(
      duration: const Duration(milliseconds: 400),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          gradient: isDark 
            ? const LinearGradient(
                colors: [Color(0xFF2C2C2C), Color(0xFF1E1E1E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.orange.withValues(alpha: isDark ? 0.1 : 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // COLUMNA 1: BALANCE Y CONTROL
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'BALANCE DE CUENTA',
                          style: TextStyle(
                            color: Colors.orange.shade400,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => context.read<ThemeCubit>().togglePrivacyMode(),
                          child: Icon(
                            isPrivacyActive ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            size: 14,
                            color: Colors.orange.shade400.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    else
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: PrivacyAmountText(
                          amount: '${humanizeNumbers.number(displayedBalance, isPrivacyModeActive: isPrivacyActive)}€',
                          isPrivacyActive: isPrivacyActive,
                          style: TextStyle(
                            color: isDark ? Colors.white : colorScheme.onSurface,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 12),
                    
                    GestureDetector(
                      onTap: () => context.read<TotalMoneyCubit>().toggleSavingsInclusion(),
                      child: _ModeChip(
                        isSavingsIncluded: totalMoneyState.isSavingsIncluded,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 15),

              // COLUMNA 2: BURBUJA DE AHORROS
              _SavingsBubble(
                savingsState: savingsState, 
                isGoalMet: isGoalMet, 
                humanizeNumbers: humanizeNumbers,
                isPrivacyActive: isPrivacyActive,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavingsBubble extends StatelessWidget {
  final SavingsCubitState savingsState;
  final bool isGoalMet;
  final HumanizeNumbers humanizeNumbers;
  final bool isPrivacyActive;

  const _SavingsBubble({
    required this.savingsState, 
    required this.isGoalMet, 
    required this.humanizeNumbers,
    required this.isPrivacyActive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(barrierDismissible: false, context: context, builder: (context) => const SavingsDialog());
      },
      onLongPress: () {
        if (savingsState.savingGoal > 0) {
          showDialog(barrierDismissible: false, context: context, builder: (context) => const DeleteSavingsGoalDialog());
        } else {
          showDialog(barrierDismissible: false, context: context, builder: (context) => const SavingsGoalDialog());
        }
      },
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isGoalMet ? Colors.green.withValues(alpha: 0.05) : Colors.orange.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isGoalMet ? Colors.green.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('AHORROS', style: const TextStyle(fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                  if (isGoalMet) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.check_circle, size: 9, color: Colors.green)
                  ]
                ],
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: PrivacyAmountText(
                amount: '${humanizeNumbers.number(savingsState.savingTotal, isPrivacyModeActive: isPrivacyActive)}€',
                isPrivacyActive: isPrivacyActive,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: isGoalMet ? Colors.green : Colors.orange),
              ),
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: isPrivacyActive ? 0.0 : savingsState.progress, 
                minHeight: 3, 
                backgroundColor: (isGoalMet ? Colors.green : Colors.orange).withValues(alpha: 0.1), 
                valueColor: AlwaysStoppedAnimation<Color>(isGoalMet ? Colors.green : Colors.orange)
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: PrivacyAmountText(
                amount: 'Meta: ${humanizeNumbers.number(savingsState.savingGoal, isPrivacyModeActive: isPrivacyActive)}€',
                isPrivacyActive: isPrivacyActive,
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: isGoalMet ? Colors.green.withValues(alpha: 0.7) : Colors.orange.withValues(alpha: 0.7)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final bool isSavingsIncluded;
  final bool isDark;

  const _ModeChip({required this.isSavingsIncluded, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = Colors.orange.shade400;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sync_rounded, color: color.withValues(alpha: 0.8), size: 12),
            const SizedBox(width: 6),
            Text(
              isSavingsIncluded ? 'AHORROS SUMADOS' : 'SOLO CARTERA',
              style: TextStyle(
                color: isDark ? Colors.white70 : colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
