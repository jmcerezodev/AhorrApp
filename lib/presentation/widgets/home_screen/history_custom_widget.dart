import 'package:animate_do/animate_do.dart';
import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/dialogs.dart';
import 'package:ahorrapp/presentation/widgets/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class HistoryCustomWidget extends StatelessWidget {
  const HistoryCustomWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final historyCubit = context.watch<HistoryCubit>();
    final dateCubit = context.watch<DateCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;

    final List<Map<String, dynamic>> filteredListDate = historyCubit.state.historyList.where((item) {
      return item["year"] == dateCubit.year && item["month"] == dateCubit.month;
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                historyCubit.state.isChart ? 'ANÁLISIS ANUAL' : 'MOVIMIENTOS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                  letterSpacing: 2.0,
                ),
              ),
              Row(
                children: [
                  if (!historyCubit.state.isChart)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        final newOrder = historyCubit.state.listOrder == 'descending' ? 'ascending' : 'descending';
                        context.read<HistoryCubit>().listOrder(newOrder);
                      },
                      icon: Icon(Icons.sort_rounded, color: colorScheme.primary.withValues(alpha: 0.6), size: 20),
                    ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      historyCubit.state.isChart ? Icons.list_alt_rounded : Icons.bar_chart_rounded,
                      color: colorScheme.primary.withValues(alpha: 0.6),
                      size: 22,
                    ),
                    onPressed: () => context.read<HistoryCubit>().isChart(!historyCubit.state.isChart),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 5),
          
          Expanded(
            child: historyCubit.state.isChart
                ? FadeInRight(child: const ChartHistory())
                : _HistoryList(filteredListDate: filteredListDate),
          ),
        ],
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<Map<String, dynamic>> filteredListDate;
  const _HistoryList({required this.filteredListDate});

  @override
  Widget build(BuildContext context) {
    final historyCubit = context.watch<HistoryCubit>();
    final colorScheme = Theme.of(context).colorScheme;
    final items = historyCubit.state.listOrder == 'descending' 
        ? filteredListDate 
        : filteredListDate.reversed.toList();

    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: Text(
          'No hay movimientos este mes.',
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.3), 
            fontStyle: FontStyle.italic
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) => _HistoryItem(item: items[index]),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final Map<String, dynamic> item;
  const _HistoryItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final humanizeNumbers = HumanizeNumbers();
    final isIncome = item['isIncome'] == true;
    final money = humanizeNumbers.number((item['money'] as num).toDouble());
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(item['id']),
        background: _SwipeBackground(
          color: Colors.green.shade400,
          icon: Icons.edit_rounded,
          alignment: Alignment.centerLeft,
        ),
        secondaryBackground: _SwipeBackground(
          color: Colors.red.shade400,
          icon: Icons.delete_outline_rounded,
          alignment: Alignment.centerRight,
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            return showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => EditItemHistoryDialog(itemId: item['id']),
            );
          } else {
            return showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => DeleteItemHistoryDialog(itemId: item['id']),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.3), // Borde unificado
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.05), // Sombra unificada
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isIncome 
                    ? Colors.green.shade400.withValues(alpha: isDark ? 0.1 : 0.05)
                    : Colors.red.shade400.withValues(alpha: isDark ? 0.1 : 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                  color: isIncome ? Colors.green.shade400 : Colors.red.shade400,
                  size: 18,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item['currentDate']} • ${item['currentHour']}',
                      style: TextStyle(fontSize: 10, color: colorScheme.onSurface.withValues(alpha: 0.4)),
                    ),
                  ],
                ),
              ),
              Text(
                '${isIncome ? "+" : "-"}$money€',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: isIncome ? Colors.green.shade400 : Colors.red.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  final Color color;
  final IconData icon;
  final Alignment alignment;

  const _SwipeBackground({required this.color, required this.icon, required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      alignment: alignment,
      child: Icon(icon, color: Colors.white),
    );
  }
}
