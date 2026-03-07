import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/recurrent_expenses_screen/recurrent_empty_state.dart';
import 'package:ahorrapp/presentation/widgets/recurrent_expenses_screen/recurrent_expense_item.dart';
import 'package:ahorrapp/presentation/widgets/recurrent_expenses_screen/recurrent_filter_panel.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecurrentHistoryWidget extends StatelessWidget {
  const RecurrentHistoryWidget({super.key});

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
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10), // Añadido vertical: 10 para igualar Home
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

        // PANEL DE FILTROS (Modular)
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
                return Center(child: Text(state.errorMessage ?? 'Error al cargar gastos fijos'));
              }

              final filteredExpenses = state.expenses.where((e) {
                final bool isAutomatic = e.day != null;
                if (isAutomatic && !state.showAutomatic) return false;
                if (!isAutomatic && !state.showManual) return false;
                if (state.selectedCategories.isNotEmpty && !state.selectedCategories.contains(e.category.toLowerCase())) return false;
                return true;
              }).toList();

              if (filteredExpenses.isEmpty) {
                return RecurrentEmptyState(colorScheme: colorScheme, isFiltered: state.isFilterOpen);
              }

              return ReorderableListView.builder(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20), // Igualado a Home (SliverPadding)
                physics: const BouncingScrollPhysics(),
                itemCount: filteredExpenses.length,
                onReorder: (oldIndex, newIndex) {
                  final item = filteredExpenses[oldIndex];
                  final actualOldIndex = state.expenses.indexOf(item);
                  int actualNewIndex;
                  if (newIndex < filteredExpenses.length) {
                    actualNewIndex = state.expenses.indexOf(filteredExpenses[newIndex]);
                  } else {
                    actualNewIndex = state.expenses.indexOf(filteredExpenses.last) + 1;
                  }
                  context.read<RecurrentExpensesCubit>().reorderExpenses(actualOldIndex, actualNewIndex);
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
