import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/recurrent_expenses_dialogs/add_edit_recurrent_expense_dialog.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecurrentSummaryWidget extends StatelessWidget {
  final bool isIncomeTab;

  const RecurrentSummaryWidget({
    super.key,
    required this.isIncomeTab,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final humanizeNumbers = HumanizeNumbers();
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<RecurrentExpensesCubit, RecurrentExpensesState>(
      builder: (context, state) {
        // Obtenemos el total según la pestaña activa (Ingreso o Gasto)
        final double totalToShow = state.showProrated 
            ? (isIncomeTab ? state.totalIncomeProrated : state.totalExpenseProrated)
            : (isIncomeTab ? state.totalIncomeStrict : state.totalExpenseStrict);

        return FadeInDown(
          duration: const Duration(milliseconds: 1000), // Más lento
          from: 50, // Más recorrido
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
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
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isIncomeTab ? 'TOTAL INGRESOS FIJOS' : 'TOTAL GASTOS FIJOS',
                            style: TextStyle(
                              color: Colors.orange.shade400,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${humanizeNumbers.number(totalToShow)}€',
                              style: TextStyle(
                                color: isDark ? Colors.white : colorScheme.onSurface,
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          GestureDetector(
                            onTap: () => context.read<RecurrentExpensesCubit>().toggleProratedView(),
                            behavior: HitTestBehavior.opaque,
                            child: _ModeChip(
                              showProrated: state.showProrated,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 15),

                    _AddRecurrentBubble(isIncome: isIncomeTab),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AddRecurrentBubble extends StatelessWidget {
  final bool isIncome;
  const _AddRecurrentBubble({required this.isIncome});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AddEditRecurrentExpenseDialog(isIncome: isIncome),
        );
      },
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.orange.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_box_rounded,
              color: Colors.orange,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              isIncome ? 'NUEVO INGRESO' : 'NUEVO GASTO',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: Colors.orange,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final bool showProrated;
  final bool isDark;

  const _ModeChip({
    required this.showProrated, 
    required this.isDark
  });

  @override
  Widget build(BuildContext context) {
    final color = Colors.orange.shade400;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sync_rounded, color: color.withValues(alpha: 0.8), size: 12),
          const SizedBox(width: 6),
          Text(
            showProrated ? 'TOTAL PRORRATEADO' : 'TOTAL MENSUAL',
            style: TextStyle(
              color: isDark ? Colors.white70 : colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
