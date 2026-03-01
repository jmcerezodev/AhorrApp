import 'package:ahorrapp/core/date/date.dart';
import 'package:ahorrapp/core/di/service_locator.dart';
import 'package:ahorrapp/data/local/local_db_service.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animate_do/animate_do.dart';

class CalendarPanelWidget extends StatefulWidget {
  const CalendarPanelWidget({super.key});

  @override
  State<CalendarPanelWidget> createState() => _CalendarPanelWidgetState();
}

class _CalendarPanelWidgetState extends State<CalendarPanelWidget> {
  Map<String, Map<String, bool>> _activityMap = {};
  int _minYear = 2024;
  late LocalDbService _localDb;

  @override
  void initState() {
    super.initState();
    // CORREGIDO: Inicialización segura para tests
    _localDb = getIt<LocalDbService>();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final minYear = await _localDb.getMinYear();
    if (mounted) {
      setState(() {
        _minYear = minYear;
      });
      _loadYearlyActivity();
    }
  }

  Future<void> _loadYearlyActivity() async {
    final dateCubit = context.read<DateCubit>().state;
    final yearData = await _localDb.getYearlyActivity(dateCubit.year);
    
    final Map<String, Map<String, bool>> newMap = {};
    for (var item in yearData) {
      final String m = item.month;
      newMap.putIfAbsent(m, () => {'hasIncome': false, 'hasExpense': false});
      if (item.type == 'income') {
        newMap[m]!['hasIncome'] = true;
      } else if (item.type == 'expense') {
        newMap[m]!['hasExpense'] = true;
      }
    }

    if (mounted) {
      setState(() {
        _activityMap = newMap;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateCubit = context.watch<DateCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final DateTime now = DateTime.now();
    final int currentYear = now.year;
    final int currentMonthIndex = now.month;

    final List<String> months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];

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
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 5, 5, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          Icons.chevron_left_rounded, 
                          color: dateCubit.year > _minYear ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.1), 
                          size: 28
                        ),
                        onPressed: dateCubit.year > _minYear ? () {
                          context.read<DateCubit>().yearDecrement(1);
                          _loadYearlyActivity();
                        } : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          dateCubit.year.toString(),
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: colorScheme.onSurface),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          Icons.chevron_right_rounded, 
                          color: dateCubit.year < currentYear ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.1), 
                          size: 28
                        ),
                        onPressed: dateCubit.year < currentYear ? () {
                          context.read<DateCubit>().yearIncrement(1);
                          _loadYearlyActivity();
                        } : null,
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
                children: months.asMap().entries.map((entry) {
                  final int index = entry.key + 1;
                  final String monthName = entry.value;
                  final bool isFuture = (dateCubit.year == currentYear && index > currentMonthIndex);
                  
                  final activity = _activityMap[monthName] ?? {'hasIncome': false, 'hasExpense': false};
                  
                  return _MonthItem(
                    monthName: monthName,
                    hasIncome: activity['hasIncome']!,
                    hasExpense: activity['hasExpense']!,
                    isEnabled: !isFuture,
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

class _MonthItem extends StatelessWidget {
  final String monthName;
  final bool hasIncome;
  final bool hasExpense;
  final bool isEnabled;

  const _MonthItem({
    required this.monthName,
    required this.hasIncome,
    required this.hasExpense,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final selectedMonth = context.watch<DateCubit>().state.month;
    final isSelected = selectedMonth == monthName;
    final colorScheme = Theme.of(context).colorScheme;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.2,
      child: InkWell(
        onTap: isEnabled ? () {
          context.read<DateCubit>().month(monthName);
          context.read<DateCubit>().isOpen(false);
        } : null,
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
      ),
    );
  }
}
