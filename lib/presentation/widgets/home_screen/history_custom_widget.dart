import 'package:animate_do/animate_do.dart';
import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/saving_dialogs/edit_saving_dialog.dart';
import 'package:ahorrapp/presentation/widgets/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class HistoryCustomWidget extends StatelessWidget {
  const HistoryCustomWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final historyCubit = context.watch<HistoryCubit>();
    final dateState = context.watch<DateCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;

    // FILTRO DINÁMICO
    final List<Map<String, dynamic>> filteredList = historyCubit.state.historyList.where((item) {
      final String itemYear = item["year"].toString();
      final String itemMonth = item["month"].toString().trim().toLowerCase();
      
      final String selectedYear = dateState.year.toString();
      final String selectedMonth = dateState.month.toString().trim().toLowerCase();

      final bool isCorrectDate = (itemYear == selectedYear) && (itemMonth == selectedMonth);
      
      bool isTypeVisible = false;
      if (item['type'] == 'income' && historyCubit.state.showIncomes) isTypeVisible = true;
      if (item['type'] == 'expense' && historyCubit.state.showExpenses) isTypeVisible = true;
      if (item['type'] == 'saving' && historyCubit.state.showSavings) isTypeVisible = true;

      return isCorrectDate && isTypeVisible;
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
                    _FilterMenuButton(),
                  
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
                    onPressed: () => historyCubit.isChart(!historyCubit.state.isChart),
                  ),
                ],
              ),
            ],
          ),
          
          if (historyCubit.state.isFilterOpen && !historyCubit.state.isChart)
            FadeInDown(
              duration: const Duration(milliseconds: 200),
              child: _FilterPanel(historyCubit: historyCubit),
            ),

          const SizedBox(height: 5),
          
          Expanded(
            child: historyCubit.state.isChart
                ? FadeInRight(child: const ChartHistory())
                : _HistoryList(
                    filteredList: filteredList, 
                    totalItems: historyCubit.state.historyList.length,
                    selectedDate: "${dateState.month} ${dateState.year}"
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterMenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final historyCubit = context.watch<HistoryCubit>();

    return IconButton(
      visualDensity: VisualDensity.compact,
      onPressed: () => historyCubit.toggleFilterPanel(),
      icon: Icon(
        historyCubit.state.isFilterOpen ? Icons.filter_list_off_rounded : Icons.filter_list_rounded, 
        color: colorScheme.primary.withValues(alpha: 0.6), 
        size: 20
      ),
    );
  }
}

class _FilterPanel extends StatelessWidget {
  final HistoryCubit historyCubit;
  const _FilterPanel({required this.historyCubit});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10, top: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: colorScheme.primary.withValues(alpha: isDark ? 0.1 : 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _FilterChip(
            label: 'Ingresos',
            value: historyCubit.state.showIncomes,
            activeColor: Colors.green,
            onChanged: (val) => historyCubit.toggleIncomes(val),
          ),
          _FilterChip(
            label: 'Gastos',
            value: historyCubit.state.showExpenses,
            activeColor: Colors.red,
            onChanged: (val) => historyCubit.toggleExpenses(val),
          ),
          _FilterChip(
            label: 'Ahorros',
            value: historyCubit.state.showSavings,
            activeColor: colorScheme.primary,
            onChanged: (val) => historyCubit.toggleSavings(val),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool value;
  final Color activeColor;
  final Function(bool) onChanged;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: value,
            onChanged: (val) => onChanged(val!),
            activeColor: activeColor,
            visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: value ? activeColor : colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<Map<String, dynamic>> filteredList;
  final int totalItems;
  final String selectedDate;

  const _HistoryList({
    required this.filteredList, 
    required this.totalItems,
    required this.selectedDate
  });

  @override
  Widget build(BuildContext context) {
    final historyCubit = context.watch<HistoryCubit>();
    final colorScheme = Theme.of(context).colorScheme;
    
    final items = historyCubit.state.listOrder == 'descending' 
        ? filteredList 
        : filteredList.reversed.toList();

    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline_rounded, color: colorScheme.onSurface.withValues(alpha: 0.1), size: 40),
            const SizedBox(height: 10),
            Text(
              totalItems == 0 
                ? 'No hay datos en la base de datos.'
                : 'Sin movimientos en $selectedDate.',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.3), 
                fontStyle: FontStyle.italic
              ),
            ),
          ],
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    
    final double amount = (item['money'] as num).toDouble();
    final type = item['type'];
    final bool isSpent = item['isSpent'] ?? false;

    Color accentColor = Colors.orange;
    IconData icon = Icons.help_outline_rounded;
    String prefix = "";

    if (type == 'income') {
      accentColor = Colors.green.shade400;
      icon = Icons.arrow_upward_rounded;
      prefix = "";
    } else if (type == 'expense') {
      accentColor = Colors.red.shade400;
      icon = Icons.arrow_downward_rounded;
      prefix = "-";
    } else if (type == 'saving') {
      accentColor = colorScheme.primary; 
      if (amount >= 0) {
        icon = Icons.savings_rounded;
        prefix = "";
      } else {
        icon = Icons.outbox_rounded;
        prefix = "-";
      }
    }

    final moneyString = humanizeNumbers.number(amount.abs());
    
    // Solo mostramos 'GASTADO' si es una aportación positiva marcada como tal.
    // Una retirada (negativa) ya implica gasto por sí misma.
    final bool showSpentLabel = isSpent && amount >= 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Opacity(
        opacity: showSpentLabel ? 0.7 : 1.0, 
        child: Dismissible(
          key: Key(item['id']),
          background: _SwipeBackground(
            color: Colors.green.shade400,
            icon: Icons.edit_note_rounded,
            label: 'EDITAR',
            alignment: Alignment.centerLeft,
          ),
          secondaryBackground: _SwipeBackground(
            color: Colors.red.shade400,
            icon: Icons.delete_sweep_rounded,
            label: 'ELIMINAR',
            alignment: Alignment.centerRight,
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              if (type == 'saving') {
                return showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => EditSavingDialog(savingId: item['id']),
                );
              }
              return showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) => EditItemHistoryDialog(itemId: item['id']),
              );
            } else {
              if (type == 'saving') {
                return showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => DeleteSavingItemDialog(savingId: item['id']),
                );
              }
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
                color: colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.3),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.05),
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
                    color: accentColor.withValues(alpha: isDark ? 0.1 : 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: accentColor, size: 18),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              item['name'],
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                                decoration: showSpentLabel ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                          if (showSpentLabel) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                'GASTADO', 
                                style: TextStyle(
                                  fontSize: 7, 
                                  fontWeight: FontWeight.w900, 
                                  color: colorScheme.primary.withValues(alpha: 0.6)
                                )
                              ),
                            ),
                          ],
                        ],
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
                  '$prefix$moneyString€',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final Alignment alignment;

  const _SwipeBackground({
    required this.color, 
    required this.icon, 
    required this.label,
    required this.alignment
  });

  @override
  Widget build(BuildContext context) {
    final isLeft = alignment == Alignment.centerLeft;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.8), 
        borderRadius: BorderRadius.circular(20)
      ),
      alignment: alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLeft) ...[
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1)),
          ],
          if (!isLeft) ...[
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1)),
            const SizedBox(width: 10),
            Icon(icon, color: Colors.white, size: 24),
          ],
        ],
      ),
    );
  }
}
