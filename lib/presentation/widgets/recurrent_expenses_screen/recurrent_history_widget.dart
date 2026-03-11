import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/recurrent_expenses_screen/recurrent_expense_item.dart';
import 'package:ahorrapp/presentation/widgets/recurrent_expenses_screen/recurrent_filter_panel.dart';
import 'package:ahorrapp/presentation/widgets/widgets.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecurrentHistoryWidget extends StatelessWidget {
  final bool isIncomeTab;

  const RecurrentHistoryWidget({
    super.key,
    required this.isIncomeTab,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final humanizeNumbers = HumanizeNumbers();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CABECERA DE LISTADO CON FILTRO
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isIncomeTab ? 'LISTADO DE INGRESOS' : 'LISTADO DE GASTOS',
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

        // PANEL DE FILTROS
        BlocBuilder<RecurrentExpensesCubit, RecurrentExpensesState>(
          builder: (context, state) {
            if (state.isFilterOpen) {
              return FadeInDown(
                duration: const Duration(milliseconds: 200),
                child: RecurrentFilterPanel(cubit: context.read<RecurrentExpensesCubit>()),
              );
            }
            return const SizedBox.shrink();
          },
        ),

        Expanded(
          child: BlocBuilder<RecurrentExpensesCubit, RecurrentExpensesState>(
            builder: (context, state) {
              if (state.status == RecurrentExpensesStatus.loading && state.expenses.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == RecurrentExpensesStatus.failure) {
                return Center(child: Text(state.errorMessage ?? 'Error al cargar registros fijos'));
              }

              final filteredExpenses = state.expenses.where((e) {
                // 1. Filtrar por pestaña (Ingreso/Gasto)
                if (e.isIncome != isIncomeTab) return false;
                
                // 2. Otros filtros
                final bool isAutomatic = e.day != null;
                if (isAutomatic && !state.showAutomatic) return false;
                if (!isAutomatic && !state.showManual) return false;
                if (state.selectedCategories.isNotEmpty && !state.selectedCategories.contains(e.category.toLowerCase())) return false;
                return true;
              }).toList();

              if (filteredExpenses.isEmpty) {
                return EmptyListWidget(
                  text: state.isFilterOpen 
                    ? 'No hay registros que coincidan con los filtros seleccionados.'
                    : (isIncomeTab 
                        ? 'Añade tus ingresos recurrentes para que la app los anote automáticamente.'
                        : 'Añade tus facturas o suscripciones para que la app las anote automáticamente.'),
                );
              }

              return ReorderableListView.builder(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
                physics: const BouncingScrollPhysics(),
                itemCount: filteredExpenses.length,
                onReorder: (oldIndex, newIndex) {
                  context.read<RecurrentExpensesCubit>().reorderExpenses(
                    oldIndex, 
                    newIndex, 
                    isIncome: isIncomeTab
                  );
                },
                itemBuilder: (context, index) {
                  final expense = filteredExpenses[index];
                  return RecurrentExpenseItem(
                    key: ValueKey(expense.id),
                    expense: expense,
                    index: index,
                    humanizeNumbers: humanizeNumbers,
                    colorScheme: colorScheme,
                    isDark: isDark,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
