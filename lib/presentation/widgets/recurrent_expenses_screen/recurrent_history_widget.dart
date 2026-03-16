import 'package:ahorrapp/core/config/responsive_utils.dart';
import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/recurrent_expenses_screen/recurrent_expense_item.dart';
import 'package:ahorrapp/presentation/widgets/recurrent_expenses_screen/recurrent_filter_panel.dart';
import 'package:ahorrapp/presentation/widgets/widgets.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecurrentHistoryWidget extends StatefulWidget {
  final bool isIncomeTab;

  const RecurrentHistoryWidget({
    super.key,
    required this.isIncomeTab,
  });

  @override
  State<RecurrentHistoryWidget> createState() => _RecurrentHistoryWidgetState();
}

class _RecurrentHistoryWidgetState extends State<RecurrentHistoryWidget> {
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) setState(() => _hasAnimated = true);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final humanizeNumbers = HumanizeNumbers();

    return BlocBuilder<RecurrentExpensesCubit, RecurrentExpensesState>(
      builder: (context, state) {
        if (state.status == RecurrentExpensesStatus.loading && state.expenses.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == RecurrentExpensesStatus.failure) {
          return Center(child: Text(state.errorMessage ?? 'Error al cargar registros fijos'));
        }

        final List<dynamic> filteredExpenses = state.expenses
            .where((e) => e.isIncome == widget.isIncomeTab)
            .toList()
          ..sort((a, b) => a.position.compareTo(b.position));

        final displayedExpenses = filteredExpenses.where((e) {
          // Filtro por búsqueda
          if (state.searchQuery.isNotEmpty) {
            final query = state.searchQuery.toLowerCase();
            if (!e.name.toLowerCase().contains(query) && 
                !e.category.toLowerCase().contains(query)) {
              return false;
            }
          }

          final bool isAutomatic = e.day != null;
          if (isAutomatic && !state.showAutomatic) return false;
          if (!isAutomatic && !state.showManual) return false;
          if (state.selectedCategories.isNotEmpty && !state.selectedCategories.contains(e.category.toLowerCase())) return false;
          return true;
        }).toList();

        return Column(
          children: [
            // 1. CABECERA DE LISTADO CON FILTRO (ESTÁTICA)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      widget.isIncomeTab ? 'LISTADO DE INGRESOS' : 'LISTADO DE GASTOS',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => context.read<RecurrentExpensesCubit>().toggleFilterPanel(),
                    icon: Icon(
                      state.isFilterOpen ? Icons.filter_list_off_rounded : Icons.filter_list_rounded, 
                      color: colorScheme.primary.withValues(alpha: 0.6), 
                      size: 18.w
                    ),
                  ),
                ],
              ),
            ),

            // 2. PANEL DE FILTROS ANIMADO (ESTÁTICO)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: state.isFilterOpen
                  ? RecurrentFilterPanel(cubit: context.read<RecurrentExpensesCubit>())
                  : const SizedBox(width: double.infinity, height: 0),
            ),

            // 3. LISTADO (SCROLLABLE)
            Expanded(
              child: displayedExpenses.isEmpty
                  ? EmptyListWidget(
                      text: state.searchQuery.isNotEmpty
                        ? 'No se han encontrado resultados para "${state.searchQuery}"'
                        : (state.isFilterOpen 
                          ? 'No hay registros que coincidan con los filtros seleccionados.'
                          : (widget.isIncomeTab 
                              ? 'Añade tus ingresos recurrentes para que la app los anote automáticamente.'
                              : 'Añade tus facturas o suscripciones para que la app las anote automáticamente.')),
                    )
                  : ReorderableListView.builder(
                      padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 10.h, bottom: 100.h),
                      physics: const BouncingScrollPhysics(),
                      itemCount: displayedExpenses.length,
                      onReorder: (oldIndex, newIndex) {
                        context.read<RecurrentExpensesCubit>().reorderExpenses(
                          oldIndex, 
                          newIndex, 
                          isIncome: widget.isIncomeTab
                        );
                      },
                      itemBuilder: (context, index) {
                        final expense = displayedExpenses[index];
                        final item = RecurrentExpenseItem(
                          expense: expense,
                          index: index,
                          humanizeNumbers: humanizeNumbers,
                          colorScheme: colorScheme,
                          isDark: isDark,
                        );

                        if (_hasAnimated) return Container(key: ValueKey(expense.id), child: item);

                        return FadeInUp(
                          key: ValueKey(expense.id),
                          duration: const Duration(milliseconds: 400),
                          delay: Duration(milliseconds: index * 30),
                          from: 30.h,
                          child: item,
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
