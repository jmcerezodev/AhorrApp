import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/recurrent_expenses_screen/recurrent_expense_item.dart';
import 'package:ahorrapp/presentation/widgets/recurrent_expenses_screen/recurrent_filter_panel.dart';
import 'package:ahorrapp/presentation/widgets/widgets.dart';
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

        // PANEL DE FILTROS ANIMADO
        BlocBuilder<RecurrentExpensesCubit, RecurrentExpensesState>(
          builder: (context, state) {
            return AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: state.isFilterOpen
                  ? RecurrentFilterPanel(cubit: context.read<RecurrentExpensesCubit>())
                  : const SizedBox(width: double.infinity, height: 0),
            );
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

              final List<dynamic> filteredExpenses = state.expenses
                  .where((e) => e.isIncome == isIncomeTab)
                  .toList()
                ..sort((a, b) => a.position.compareTo(b.position));

              final displayedExpenses = filteredExpenses.where((e) {
                final bool isAutomatic = e.day != null;
                if (isAutomatic && !state.showAutomatic) return false;
                if (!isAutomatic && !state.showManual) return false;
                if (state.selectedCategories.isNotEmpty && !state.selectedCategories.contains(e.category.toLowerCase())) return false;
                return true;
              }).toList();

              if (displayedExpenses.isEmpty) {
                return EmptyListWidget(
                  text: state.isFilterOpen 
                    ? 'No hay registros que coincidan con los filtros seleccionados.'
                    : (isIncomeTab 
                        ? 'Añade tus ingresos recurrentes para que la app los anote automáticamente.'
                        : 'Añade tus facturas o suscripciones para que la app las anote automáticamente.'),
                );
              }

              // La animación principal (FadeInUp) se maneja ahora desde la pantalla (Screen)
              // para asegurar que todo el bloque de la lista suba de forma coordinada.
              return ReorderableListView.builder(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
                physics: const BouncingScrollPhysics(),
                itemCount: displayedExpenses.length,
                onReorder: (oldIndex, newIndex) {
                  context.read<RecurrentExpensesCubit>().reorderExpenses(
                    oldIndex, 
                    newIndex, 
                    isIncome: isIncomeTab
                  );
                },
                itemBuilder: (context, index) {
                  final expense = displayedExpenses[index];
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
