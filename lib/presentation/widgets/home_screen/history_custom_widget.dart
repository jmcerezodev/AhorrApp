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
    final dateState = context.watch<DateCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;

    // FILTRO DINÁMICO
    final List<Map<String, dynamic>> filteredList = historyCubit.state.historyList.where((item) {
      final String itemYear = item["year"].toString();
      final String itemMonth = item["month"].toString().trim().toLowerCase();
      
      final String selectedYear = dateState.year.toString();
      final String selectedMonth = dateState.month.toString().trim().toLowerCase();

      final bool isCorrectDate = (itemYear == selectedYear) && (itemMonth == selectedMonth);
      
      // Filtro por Tipo (Ingreso/Gasto/Ahorro)
      bool isTypeVisible = false;
      if (item['type'] == 'income' && historyCubit.state.showIncomes) isTypeVisible = true;
      if (item['type'] == 'expense' && historyCubit.state.showExpenses) isTypeVisible = true;
      if (item['type'] == 'saving' && historyCubit.state.showSavings) isTypeVisible = true;

      // Filtro por Categoría
      bool isCategoryVisible = true;
      if (historyCubit.state.selectedCategories.isNotEmpty) {
        final String itemCategory = (item['category'] ?? 'otro').toString().toLowerCase();
        isCategoryVisible = historyCubit.state.selectedCategories.contains(itemCategory);
      }

      return isCorrectDate && isTypeVisible && isCategoryVisible;
    }).toList();

    // Ordenación
    final items = historyCubit.state.listOrder == 'descending' 
        ? filteredList 
        : filteredList.reversed.toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. CABECERA Y FILTROS
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 35, 
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        historyCubit.state.isChart ? 'ANÁLISIS ANUAL' : 'MOVIMIENTOS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                          letterSpacing: 1.5,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!historyCubit.state.isChart)
                            _FilterMenuButton(),
                          
                          if (!historyCubit.state.isChart)
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(6), 
                              onPressed: () {
                                final newOrder = historyCubit.state.listOrder == 'descending' ? 'ascending' : 'descending';
                                context.read<HistoryCubit>().listOrder(newOrder);
                              },
                              icon: Icon(Icons.sort_rounded, color: colorScheme.primary.withValues(alpha: 0.6), size: 18),
                            ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6), 
                            icon: Icon(
                              historyCubit.state.isChart ? Icons.list_alt_rounded : Icons.bar_chart_rounded,
                              color: colorScheme.primary.withValues(alpha: 0.6),
                              size: 20,
                            ),
                            onPressed: () => historyCubit.isChart(!historyCubit.state.isChart),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                if (historyCubit.state.isFilterOpen && !historyCubit.state.isChart)
                  FadeInDown(
                    duration: const Duration(milliseconds: 200),
                    child: _FilterPanel(historyCubit: historyCubit),
                  ),
                
                const SizedBox(height: 5),
              ],
            ),
          ),

          // 2. CONTENIDO (Gráfico o Lista)
          if (historyCubit.state.isChart)
            SliverToBoxAdapter(
              child: FadeInRight(child: const ChartHistory()),
            )
          else if (items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(
                showIncomes: historyCubit.state.showIncomes,
                showExpenses: historyCubit.state.showExpenses,
                showSavings: historyCubit.state.showSavings,
                selectedDate: "${dateState.month} de ${dateState.year}"
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _HistoryItem(item: items[index]),
                  childCount: items.length,
                ),
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
      constraints: const BoxConstraints(),
      padding: const EdgeInsets.all(6), 
      onPressed: () => historyCubit.toggleFilterPanel(),
      icon: Icon(
        historyCubit.state.isFilterOpen ? Icons.filter_list_off_rounded : Icons.filter_list_rounded, 
        color: colorScheme.primary.withValues(alpha: 0.6), 
        size: 18
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
    final state = historyCubit.state;

    return Container(
      margin: const EdgeInsets.only(bottom: 8, top: 2), 
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.primary.withValues(alpha: isDark ? 0.1 : 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _FilterChip(
                label: 'Ingresos',
                value: state.showIncomes,
                activeColor: Colors.green,
                onChanged: (val) => historyCubit.toggleIncomes(val),
              ),
              _FilterChip(
                label: 'Gastos',
                value: state.showExpenses,
                activeColor: Colors.red.shade400,
                onChanged: (val) => historyCubit.toggleExpenses(val),
              ),
              _FilterChip(
                label: 'Ahorros',
                value: state.showSavings,
                activeColor: Colors.orange,
                onChanged: (val) => historyCubit.toggleSavings(val),
              ),
            ],
          ),
          
          if (state.showIncomes) ...[
            const _FilterSectionTitle(title: 'CATEGORÍAS DE INGRESOS'),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _CategoryFilterItem(id: 'nómina', icon: Icons.work_rounded, isSelected: state.selectedCategories.contains('nómina'), onTap: () => historyCubit.toggleCategoryFilter('nómina'), color: Colors.green),
                _CategoryFilterItem(id: 'bizum', icon: Icons.send_to_mobile_rounded, isSelected: state.selectedCategories.contains('bizum'), onTap: () => historyCubit.toggleCategoryFilter('bizum'), color: Colors.green),
                _CategoryFilterItem(id: 'regalo', icon: Icons.card_giftcard_rounded, isSelected: state.selectedCategories.contains('regalo'), onTap: () => historyCubit.toggleCategoryFilter('regalo'), color: Colors.green),
                _CategoryFilterItem(id: 'inversión', icon: Icons.show_chart_rounded, isSelected: state.selectedCategories.contains('inversión'), onTap: () => historyCubit.toggleCategoryFilter('inversión'), color: Colors.green),
              ],
            ),
          ],

          if (state.showExpenses) ...[
            const _FilterSectionTitle(title: 'CATEGORÍAS DE GASTOS'),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _CategoryFilterItem(id: 'hogar', icon: Icons.home_work_rounded, isSelected: state.selectedCategories.contains('hogar'), onTap: () => historyCubit.toggleCategoryFilter('hogar'), color: Colors.red.shade400),
                _CategoryFilterItem(id: 'suscripción', icon: Icons.subscriptions_rounded, isSelected: state.selectedCategories.contains('suscripción'), onTap: () => historyCubit.toggleCategoryFilter('suscripción'), color: Colors.red.shade400),
                _CategoryFilterItem(id: 'transporte', icon: Icons.directions_car_rounded, isSelected: state.selectedCategories.contains('transporte'), onTap: () => historyCubit.toggleCategoryFilter('transporte'), color: Colors.red.shade400),
                _CategoryFilterItem(id: 'ocio', icon: Icons.sports_esports_rounded, isSelected: state.selectedCategories.contains('ocio'), onTap: () => historyCubit.toggleCategoryFilter('ocio'), color: Colors.red.shade400),
                _CategoryFilterItem(id: 'salud', icon: Icons.favorite_rounded, isSelected: state.selectedCategories.contains('salud'), onTap: () => historyCubit.toggleCategoryFilter('salud'), color: Colors.red.shade400),
                _CategoryFilterItem(id: 'general', icon: Icons.receipt_long_rounded, isSelected: state.selectedCategories.contains('general'), onTap: () => historyCubit.toggleCategoryFilter('general'), color: Colors.red.shade400),
              ],
            ),
          ],

          if (state.showIncomes || state.showExpenses) ...[
            const _FilterSectionTitle(title: 'OTROS'),
            _CategoryFilterItem(id: 'otro', icon: Icons.more_horiz_rounded, isSelected: state.selectedCategories.contains('otro'), onTap: () => historyCubit.toggleCategoryFilter('otro'), color: Colors.grey),
          ],
        ],
      ),
    );
  }
}

class _FilterSectionTitle extends StatelessWidget {
  final String title;
  const _FilterSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider(height: 1, thickness: 0.5)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: Colors.blueGrey.shade300,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const Expanded(child: Divider(height: 1, thickness: 0.5)),
        ],
      ),
    );
  }
}

class _CategoryFilterItem extends StatelessWidget {
  final String id;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _CategoryFilterItem({required this.id, required this.icon, required this.isSelected, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? color : color.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Icon(icon, size: 16, color: isSelected ? Colors.white : color.withValues(alpha: 0.6)),
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
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: (value ? activeColor : colorScheme.onSurface).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                value ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: value ? activeColor : colorScheme.onSurface.withValues(alpha: 0.3),
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 10, 
                fontWeight: FontWeight.w900,
                color: value ? activeColor : colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool showIncomes;
  final bool showExpenses;
  final bool showSavings;
  final String selectedDate;

  const _EmptyState({
    required this.showIncomes,
    required this.showExpenses,
    required this.showSavings,
    required this.selectedDate
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    String message = '';
    List<String> active = [];
    if (showIncomes) active.add('ingresos');
    if (showExpenses) active.add('gastos');
    if (showSavings) active.add('ahorros');

    if (active.isEmpty) {
      message = 'No hay filtros seleccionados';
    } else if (active.length == 3) {
      message = 'Sin movimientos en el mes de $selectedDate';
    } else {
      String filterText = active.join(' ni ');
      message = 'Sin $filterText en el mes de $selectedDate';
    }

    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline_rounded, color: colorScheme.onSurface.withValues(alpha: 0.1), size: 40),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.3), 
              fontStyle: FontStyle.italic
            ),
          ),
        ],
      ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final double amount = (item['money'] as num).toDouble();
    final type = item['type'];
    final bool isSpent = item['isSpent'] ?? false;
    final bool isRecurrent = item['isRecurrent'] ?? false;
    final String category = item['category'] ?? (type == 'income' ? 'otro' : 'general');

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
    
    final bool showSpentLabel = isSpent && amount >= 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8), 
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
                          if (isRecurrent) ...[
                            const SizedBox(width: 6),
                            Icon(Icons.repeat_rounded, size: 14, color: Colors.orange.withValues(alpha: 0.8)),
                          ],
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
                      Row(
                        children: [
                          Text(
                            '${item['currentDate']} • ${item['currentHour']}',
                            style: TextStyle(fontSize: 10, color: colorScheme.onSurface.withValues(alpha: 0.4)),
                          ),
                          if (type != 'saving') ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                category.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 7, 
                                  fontWeight: FontWeight.w900, 
                                  color: accentColor.withValues(alpha: 0.6)
                                )
                              ),
                            ),
                          ],
                        ],
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
