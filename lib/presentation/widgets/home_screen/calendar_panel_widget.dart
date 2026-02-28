import 'package:animate_do/animate_do.dart';
import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/core/filter_lists/filter_lists.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CalendarPanelWidget extends StatelessWidget {
  const CalendarPanelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final filterLists = FilterLists();
    final dateCubit = context.watch<DateCubit>().state;
    final historyList = context.watch<HistoryCubit>().state.historyList;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final int historyMinYear = filterLists.findMinYear(historyList);
    final int minYear = historyMinYear < 2024 ? historyMinYear : 2024;
    final int maxYear = int.parse(Date().year());

    final Map<String, Map<String, bool>> activityMap = {};
    for (var item in historyList) {
      if (item['year'] == dateCubit.year) {
        final String m = item['month'];
        activityMap.putIfAbsent(m, () => {'hasIncome': false, 'hasExpense': false});
        if (item['isIncome'] == true) {
          activityMap[m]!['hasIncome'] = true;
        } else {
          activityMap[m]!['hasExpense'] = true;
        }
      }
    }

    return FadeInDown(
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cabecera con selector de año y botón de cerrar
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 5, 5, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40), // Espaciador para centrar el año
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _YearButton(
                        icon: Icons.chevron_left_rounded,
                        enabled: dateCubit.year > minYear, 
                        onPressed: () => context.read<DateCubit>().yearDecrement(1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          dateCubit.year.toString(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      _YearButton(
                        icon: Icons.chevron_right_rounded,
                        enabled: dateCubit.year < maxYear,
                        onPressed: () => context.read<DateCubit>().yearIncrement(1),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => context.read<DateCubit>().isOpen(false),
                    icon: Icon(Icons.close_rounded, color: colorScheme.onSurface.withValues(alpha: 0.3), size: 22),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, indent: 20, endIndent: 20),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  'Enero', 'Febrero', 'Marzo', 'Abril', 
                  'Mayo', 'Junio', 'Julio', 'Agosto', 
                  'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
                ].map((month) {
                  final activity = activityMap[month] ?? {'hasIncome': false, 'hasExpense': false};
                  return _MonthItem(
                    monthName: month,
                    hasIncome: activity['hasIncome']!,
                    hasExpense: activity['hasExpense']!,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _YearButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  const _YearButton({required this.icon, required this.enabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      visualDensity: VisualDensity.compact,
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon, color: enabled ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.1), size: 28),
    );
  }
}

class _MonthItem extends StatelessWidget {
  final String monthName;
  final bool hasIncome;
  final bool hasExpense;

  const _MonthItem({
    required this.monthName,
    required this.hasIncome,
    required this.hasExpense,
  });

  @override
  Widget build(BuildContext context) {
    final selectedMonth = context.watch<DateCubit>().state.month;
    final isSelected = selectedMonth == monthName;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        context.read<DateCubit>().month(monthName);
        context.read<DateCubit>().isOpen(false); // CERRAR AL PULSAR UN MES
      },
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: MediaQuery.of(context).size.width * 0.20,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.primary.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Text(
              monthName.substring(0, 3),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasIncome)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.green.shade400,
                      shape: BoxShape.circle,
                    ),
                  ),
                if (hasIncome && hasExpense) const SizedBox(width: 3),
                if (hasExpense)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : colorScheme.primary.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
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
