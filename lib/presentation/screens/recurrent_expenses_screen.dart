import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/recurrent_expenses_dialogs/add_edit_recurrent_expense_dialog.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/recurrent_expenses_dialogs/confirm_manual_payment_dialog.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/recurrent_expenses_dialogs/delete_recurrent_expense_dialog.dart';
import 'package:ahorrapp/presentation/widgets/shared/swipe_background_widget.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecurrentExpensesScreen extends StatefulWidget {
  const RecurrentExpensesScreen({super.key});

  @override
  State<RecurrentExpensesScreen> createState() => _RecurrentExpensesScreenState();
}

class _RecurrentExpensesScreenState extends State<RecurrentExpensesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RecurrentExpensesCubit>().loadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final humanizeNumbers = HumanizeNumbers();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 10, 20, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MIS PAGOS FIJOS',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Planifica tus gastos mensuales',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const AddEditRecurrentExpenseDialog(),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.2), width: 1.5)
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.orange, size: 24),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            BlocBuilder<RecurrentExpensesCubit, RecurrentExpensesState>(
              builder: (context, state) {
                if (state.expenses.isEmpty) return const SizedBox.shrink();
                
                final double totalToShow = state.showProrated 
                    ? state.totalMonthlyNormalized 
                    : state.totalStrictlyMonthly;

                return FadeInDown(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: GestureDetector(
                      onTap: () => context.read<RecurrentExpensesCubit>().toggleProratedView(),
                      child: Container(
                        width: double.infinity,
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
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: isDark ? 0.1 : 0.3), 
                            width: 1.5
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      state.showProrated 
                                        ? 'GASTOS FIJOS (PRORRATEADOS)' 
                                        : 'PAGOS FIJOS MENSUALES',
                                      style: TextStyle(
                                        color: Colors.orange.shade400,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${humanizeNumbers.number(totalToShow)}€',
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Colors.black87,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.repeat_rounded,
                                    color: Colors.orange,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 12),
                            
                            Row(
                              children: [
                                _ModeChip(
                                  label: state.showProrated ? 'PRORRATEADO' : 'SOLO MENSUALES',
                                  color: Colors.orange.shade400,
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  Icons.sync_rounded, 
                                  color: isDark ? Colors.white30 : Colors.grey.shade400, 
                                  size: 12
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  state.showProrated ? 'Cambiar a mensual' : 'Cambiar a prorrateado',
                                  style: TextStyle(
                                    color: isDark ? Colors.white30 : Colors.grey.shade500,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LISTADO DE GASTOS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface.withValues(alpha: 0.4),
                      letterSpacing: 2.0,
                    ),
                  ),
                  BlocBuilder<RecurrentExpensesCubit, RecurrentExpensesState>(
                    builder: (context, state) {
                      return IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => context.read<RecurrentExpensesCubit>().toggleFilterPanel(),
                        icon: Icon(
                          state.isFilterOpen ? Icons.filter_list_off_rounded : Icons.filter_list_rounded, 
                          color: colorScheme.primary.withValues(alpha: 0.6), 
                          size: 18
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            BlocBuilder<RecurrentExpensesCubit, RecurrentExpensesState>(
              builder: (context, state) {
                if (state.isFilterOpen) {
                  return FadeInDown(
                    duration: const Duration(milliseconds: 200),
                    child: _FilterPanel(cubit: context.read<RecurrentExpensesCubit>()),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 2),

            Expanded(
              child: BlocBuilder<RecurrentExpensesCubit, RecurrentExpensesState>(
                builder: (context, state) {
                  if (state.status == RecurrentExpensesStatus.loading && state.expenses.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == RecurrentExpensesStatus.failure) {
                    return Center(child: Text(state.errorMessage ?? 'Error al cargar gastos fijos'));
                  }

                  final filteredExpenses = state.expenses.where((e) {
                    final bool isAutomatic = e.day != null;
                    if (isAutomatic && !state.showAutomatic) return false;
                    if (!isAutomatic && !state.showManual) return false;
                    
                    if (state.selectedCategories.isNotEmpty && !state.selectedCategories.contains(e.category.toLowerCase())) {
                      return false;
                    }
                    
                    return true;
                  }).toList();

                  if (filteredExpenses.isEmpty) {
                    return _EmptyState(colorScheme: colorScheme, isFiltered: state.isFilterOpen);
                  }

                  return ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredExpenses.length,
                    onReorder: (oldIndex, newIndex) {
                      final item = filteredExpenses[oldIndex];
                      final actualOldIndex = state.expenses.indexOf(item);
                      
                      int actualNewIndex;
                      if (newIndex < filteredExpenses.length) {
                        final targetItem = filteredExpenses[newIndex];
                        actualNewIndex = state.expenses.indexOf(targetItem);
                      } else {
                        actualNewIndex = state.expenses.indexOf(filteredExpenses.last) + 1;
                      }
                      
                      context.read<RecurrentExpensesCubit>().reorderExpenses(actualOldIndex, actualNewIndex);
                    },
                    itemBuilder: (context, index) {
                      final expense = filteredExpenses[index];
                      return FadeInUp(
                        key: ValueKey(expense.id),
                        delay: Duration(milliseconds: 50 * index),
                        child: _RecurrentExpenseDismissible(
                          expense: expense,
                          humanizeNumbers: humanizeNumbers,
                          colorScheme: colorScheme,
                          isDark: isDark,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterPanel extends StatelessWidget {
  final RecurrentExpensesCubit cubit;
  const _FilterPanel({required this.cubit});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = cubit.state;

    return Container(
      margin: const EdgeInsets.only(bottom: 8, top: 2, left: 20, right: 20),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.primary.withValues(alpha: isDark ? 0.1 : 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _FilterChip(
                label: 'Automáticos',
                value: state.showAutomatic,
                activeColor: Colors.orange,
                onChanged: (val) => cubit.toggleAutomaticFilter(val),
              ),
              _FilterChip(
                label: 'Manuales',
                value: state.showManual,
                activeColor: Colors.orange,
                onChanged: (val) => cubit.toggleManualFilter(val),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            child: Divider(height: 1, thickness: 0.5),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _CategoryFilterItem(id: 'general', icon: Icons.receipt_long_rounded, isSelected: state.selectedCategories.contains('general'), onTap: () => cubit.toggleCategoryFilter('general')),
              _CategoryFilterItem(id: 'hogar', icon: Icons.home_work_rounded, isSelected: state.selectedCategories.contains('hogar'), onTap: () => cubit.toggleCategoryFilter('hogar')),
              _CategoryFilterItem(id: 'suscripción', icon: Icons.subscriptions_rounded, isSelected: state.selectedCategories.contains('suscripción'), onTap: () => cubit.toggleCategoryFilter('suscripción')),
              _CategoryFilterItem(id: 'salud', icon: Icons.favorite_rounded, isSelected: state.selectedCategories.contains('salud'), onTap: () => cubit.toggleCategoryFilter('salud')),
              _CategoryFilterItem(id: 'transporte', icon: Icons.directions_car_rounded, isSelected: state.selectedCategories.contains('transporte'), onTap: () => cubit.toggleCategoryFilter('transporte')),
              _CategoryFilterItem(id: 'ocio', icon: Icons.sports_esports_rounded, isSelected: state.selectedCategories.contains('ocio'), onTap: () => cubit.toggleCategoryFilter('ocio')),
            ],
          ),
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

  const _CategoryFilterItem({required this.id, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.orange.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? Colors.orange : Colors.orange.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.orange.withValues(alpha: 0.6)),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool value;
  final Color activeColor;
  final Function(bool) onChanged;

  const _FilterChip({required this.label, required this.value, required this.activeColor, required this.onChanged});

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
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: value ? activeColor : colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final Color color;

  const _ModeChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _RecurrentExpenseDismissible extends StatelessWidget {
  final RecurrentExpense expense;
  final HumanizeNumbers humanizeNumbers;
  final ColorScheme colorScheme;
  final bool isDark;

  const _RecurrentExpenseDismissible({
    required this.expense,
    required this.humanizeNumbers,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: Key('dismiss_${expense.id}'),
        background: const SwipeBackgroundWidget(
          color: Colors.green,
          icon: Icons.edit_note_rounded,
          label: 'EDITAR',
          alignment: Alignment.centerLeft,
        ),
        secondaryBackground: const SwipeBackgroundWidget(
          color: Colors.red,
          icon: Icons.delete_sweep_rounded,
          label: 'ELIMINAR',
          alignment: Alignment.centerRight,
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AddEditRecurrentExpenseDialog(expense: expense),
            );
            return false;
          } else {
            return await showDialog<bool>(
              context: context,
              builder: (context) => DeleteRecurrentExpenseDialog(
                expenseId: expense.id,
                expenseName: expense.name,
              ),
            );
          }
        },
        child: _RecurrentExpenseCard(
          expense: expense,
          humanizeNumbers: humanizeNumbers,
          colorScheme: colorScheme,
          isDark: isDark,
        ),
      ),
    );
  }
}

class _RecurrentExpenseCard extends StatelessWidget {
  final RecurrentExpense expense;
  final HumanizeNumbers humanizeNumbers;
  final ColorScheme colorScheme;
  final bool isDark;

  const _RecurrentExpenseCard({
    required this.expense,
    required this.humanizeNumbers,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAutomatic = expense.day != null;
    final DateTime nextPaymentDate = _calculateNextPaymentDate();
    final int daysRemaining = nextPaymentDate.difference(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)).inDays;
    final double progress = _calculateProgress(nextPaymentDate);
    final bool showProgress = isAutomatic && expense.isActive;

    return Container(
      constraints: const BoxConstraints(minHeight: 92), // UNIFORMIDAD: Altura mínima para todas
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.orange.withValues(alpha: expense.isActive ? 0.15 : 0.05),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // CENTRADO VERTICAL: Para los manuales
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
            leading: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: expense.isActive ? 0.1 : 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconForCategory(expense.category),
                    color: expense.isActive ? Colors.orange : Colors.grey,
                    size: 24,
                  ),
                ),
                if (isAutomatic)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: expense.isActive ? Colors.green.shade400 : Colors.grey.shade400,
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              expense.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: expense.isActive ? colorScheme.onSurface : colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getSubtitleText(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                if (showProgress) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 3,
                      backgroundColor: Colors.orange.withValues(alpha: 0.05),
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.withValues(alpha: 0.4)),
                    ),
                  ),
                ]
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '-${humanizeNumbers.number(expense.amount)}€',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: expense.isActive ? Colors.red.shade400 : Colors.grey,
                  ),
                ),
                const SizedBox(width: 15),
                GestureDetector(
                  onTap: () async {
                    if (isAutomatic) {
                      context.read<RecurrentExpensesCubit>().toggleActive(expense);
                    } else {
                      await showDialog<bool>(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => ConfirmManualPaymentDialog(
                          expense: expense,
                          amount: humanizeNumbers.number(expense.amount),
                        ),
                      );
                    }
                  },
                  child: Icon(
                    isAutomatic 
                      ? (expense.isActive ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded)
                      : Icons.add_circle_outline_rounded,
                    color: Colors.orange.withValues(alpha: 0.6),
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
          
          if (showProgress)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  daysRemaining == 0 ? '¡Se cobra hoy!' : 'Próximo cobro en $daysRemaining días',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: daysRemaining <= 3 ? Colors.red.shade300 : Colors.orange.withValues(alpha: 0.6),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  DateTime _calculateNextPaymentDate() {
    final now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime nextDate = DateTime(expense.startDate.year, expense.startDate.month, expense.day ?? expense.startDate.day);
    
    int monthsToAdd = 0;
    switch (expense.frequency) {
      case RecurrentFrequency.monthly: monthsToAdd = 1; break;
      case RecurrentFrequency.quarterly: monthsToAdd = 3; break;
      case RecurrentFrequency.semiAnnually: monthsToAdd = 6; break;
      case RecurrentFrequency.annually: monthsToAdd = 12; break;
    }

    if (nextDate.isAfter(now) || nextDate.isAtSameMomentAs(now)) {
      return nextDate;
    }

    while (nextDate.isBefore(now)) {
      nextDate = DateTime(nextDate.year, nextDate.month + monthsToAdd, nextDate.day);
    }
    
    return nextDate;
  }

  double _calculateProgress(DateTime nextDate) {
    final now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    
    int monthsInCycle = 1;
    switch (expense.frequency) {
      case RecurrentFrequency.monthly: monthsInCycle = 1; break;
      case RecurrentFrequency.quarterly: monthsInCycle = 3; break;
      case RecurrentFrequency.semiAnnually: monthsInCycle = 6; break;
      case RecurrentFrequency.annually: monthsInCycle = 12; break;
    }

    final prevDate = DateTime(nextDate.year, nextDate.month - monthsInCycle, nextDate.day);
    
    final totalDays = nextDate.difference(prevDate).inDays;
    final elapsedDays = now.difference(prevDate).inDays;

    if (totalDays <= 0) return 0.0;
    return (elapsedDays / totalDays).clamp(0.0, 1.0);
  }

  String _getSubtitleText() {
    if (expense.day == null) return 'Cobro manual';

    switch (expense.frequency) {
      case RecurrentFrequency.monthly:
        return 'Día ${expense.day} de cada mes';
      case RecurrentFrequency.quarterly:
        return 'Día ${expense.day} cada trimestre';
      case RecurrentFrequency.semiAnnually:
        return 'Día ${expense.day} cada 6 meses';
      case RecurrentFrequency.annually:
        return 'Día ${expense.day} cada año';
    }
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'hogar': return Icons.home_work_rounded;
      case 'suscripción': return Icons.subscriptions_rounded;
      case 'salud': return Icons.favorite_rounded;
      case 'transporte': return Icons.directions_car_rounded;
      case 'ocio': return Icons.sports_esports_rounded;
      default: return Icons.receipt_long_rounded;
    }
  }
}

class _EmptyState extends StatelessWidget {
  final ColorScheme colorScheme;
  final bool isFiltered;
  const _EmptyState({required this.colorScheme, this.isFiltered = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Opacity(
                  opacity: 0.2,
                  child: Image.asset('assets/Logo.png', height: 60, fit: BoxFit.contain),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeIn(
              delay: const Duration(milliseconds: 400),
              child: Text(
                isFiltered ? 'SIN RESULTADOS' : 'SIN GASTOS FIJOS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 10),
            FadeIn(
              delay: const Duration(milliseconds: 600),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                  isFiltered 
                    ? 'No hay gastos que coincidan con los filtros seleccionados.'
                    : 'Añade tus suscripciones o facturas mensuales para que la app las anote automáticamente por ti.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
