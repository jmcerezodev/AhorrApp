import 'package:animate_do/animate_do.dart';
import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/core/filter_lists/filter_lists.dart';
import 'package:ahorrapp/core/singletons/global_variables_singleton.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class DateCustomWidget extends StatelessWidget {
  const DateCustomWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _MonthBar(),
        Visibility(
          visible: context.select((DateCubit value) => value.state.isOpen),
          child: FadeIn(
            duration: const Duration(milliseconds: 300),
            child: const _ContainerMonthBar(),
          ),
        ),
      ],
    );
  }
}

class _MonthBar extends StatelessWidget {
  const _MonthBar();

  @override
  Widget build(BuildContext context) {
    final singleton = Singleton();
    final dateCubit = context.watch<DateCubit>();
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => dateCubit.isOpen(!dateCubit.state.isOpen),
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 20, color: colorScheme.primary),
                const SizedBox(width: 15),
                Text(
                  context.select((DateCubit value) {
                    if (value.state.month == '') {
                      value.currentMonth();
                      value.currentYear();
                    }
                    singleton.currentDate['year'] = value.state.year.toString();
                    singleton.currentDate['month'] = value.state.month;
                    return '${value.state.month}  ${value.state.year}';
                  }),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Icon(
                  dateCubit.state.isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContainerMonthBar extends StatelessWidget {
  const _ContainerMonthBar();

  @override
  Widget build(BuildContext context) {
    final filterLists = FilterLists();
    final dateCubit = context.watch<DateCubit>().state;
    final historyList = context.watch<HistoryCubit>().state.historyList;
    final colorScheme = Theme.of(context).colorScheme;

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

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _YearButton(
                    icon: Icons.chevron_left_rounded,
                    enabled: dateCubit.year > minYear, 
                    onPressed: () => context.read<DateCubit>().yearDecrement(1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      dateCubit.year.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
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
      onTap: () => context.read<DateCubit>().month(monthName),
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: MediaQuery.of(context).size.width * 0.20,
        padding: const EdgeInsets.symmetric(vertical: 8),
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
