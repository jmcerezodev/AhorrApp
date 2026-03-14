import 'package:animate_do/animate_do.dart';
import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/core/filter_lists/filter_lists.dart';
import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/core/singletons/global_variables_singleton.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/dialogs.dart';
import 'package:ahorrapp/presentation/widgets/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class ExpensesIncomesCustomWidget extends StatelessWidget {
  const ExpensesIncomesCustomWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final sigleton = Singleton();
    final humanizeNumbers = HumanizeNumbers();
    final date = Date();
    final filterLists = FilterLists();
    final colorScheme = Theme.of(context).colorScheme;
  
    final historyCubit = context.watch<HistoryCubit>().state;
    final isPrivacyActive = context.watch<ThemeCubit>().state.isPrivacyModeActive;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: FadeInLeft(
              child: _CompactActionCard(
                title: 'INGRESOS',
                money: (historyCubit.historyList.isNotEmpty) 
                    ? humanizeNumbers.number(filterLists.totalIncome(context, historyCubit.historyList), isPrivacyModeActive: isPrivacyActive) 
                    : (isPrivacyActive ? '••••' : '0'),
                isPrivacyActive: isPrivacyActive,
                icon: Icons.arrow_upward_rounded,
                iconColor: Colors.green.shade600,
                bgColor: Colors.green.shade50.withValues(alpha: colorScheme.brightness == Brightness.dark ? 0.1 : 1.0),
                borderColor: colorScheme.primary,
                glowColor: colorScheme.primary,
                onPressed: () {
                  context.read<DateCubit>().isOpen(false);
                  if ((sigleton.currentDate['month'] == date.monthNames() && (sigleton.currentDate['year'] == date.year()))) {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (dialogContext) => const IncomesDialog(),
                    );
                  } else {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (dialogContext) => const ErrorDateDialog(textDialog: 'No puedes añadir ingresos \nen una fecha diferente a la actual'),
                    );
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FadeInRight(
              child: _CompactActionCard(
                title: 'GASTOS',
                money: (historyCubit.historyList.isNotEmpty) 
                    ? humanizeNumbers.number(filterLists.totalExpense(context, historyCubit.historyList), isPrivacyModeActive: isPrivacyActive) 
                    : (isPrivacyActive ? '••••' : '0'),
                isPrivacyActive: isPrivacyActive,
                icon: Icons.arrow_downward_rounded,
                iconColor: Colors.red.shade600,
                bgColor: Colors.red.shade50.withValues(alpha: colorScheme.brightness == Brightness.dark ? 0.1 : 1.0),
                borderColor: colorScheme.primary,
                glowColor: colorScheme.primary,
                onPressed: () {
                  context.read<DateCubit>().isOpen(false);
                  if ((sigleton.currentDate['month'] == date.monthNames() && (sigleton.currentDate['year'] == date.year()))) {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (dialogContext) => const ExpensesDialog(),
                    );
                  } else {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (dialogContext) => const ErrorDateDialog(
                        textDialog: 'No puedes añadir gastos \nen una fecha diferente a la actual',
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactActionCard extends StatelessWidget {
  final String title;
  final String money;
  final bool isPrivacyActive;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final Color borderColor;
  final Color glowColor;
  final VoidCallback onPressed;

  const _CompactActionCard({
    required this.title,
    required this.money,
    required this.isPrivacyActive,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.borderColor,
    required this.glowColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                      letterSpacing: 1.0,
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: PrivacyAmountText(
                      amount: '$money€',
                      isPrivacyActive: isPrivacyActive,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
