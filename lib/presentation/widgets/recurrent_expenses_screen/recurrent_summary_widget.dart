import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecurrentSummaryWidget extends StatelessWidget {
  const RecurrentSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final humanizeNumbers = HumanizeNumbers();
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<RecurrentExpensesCubit, RecurrentExpensesState>(
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
                                color: isDark ? Colors.white : colorScheme.onSurface,
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
