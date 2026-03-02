import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/recurrent_expenses_dialogs/add_edit_recurrent_expense_dialog.dart';
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
          children: [
            // CABECERA PROFESIONAL CON BOTÓN INTEGRADO
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MIS PAGOS FIJOS',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Planifica tus gastos mensuales',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  
                  // BOTÓN DE AÑADIR ELEGANTE
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const AddEditRecurrentExpenseDialog(),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.2), width: 1.5)
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.orange, size: 28),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // LISTADO DE GASTOS
            Expanded(
              child: BlocBuilder<RecurrentExpensesCubit, RecurrentExpensesState>(
                builder: (context, state) {
                  if (state.status == RecurrentExpensesStatus.loading && state.expenses.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == RecurrentExpensesStatus.failure) {
                    return Center(child: Text(state.errorMessage ?? 'Error al cargar gastos fijos'));
                  }

                  if (state.expenses.isEmpty) {
                    return _EmptyState(colorScheme: colorScheme);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    physics: const BouncingScrollPhysics(),
                    itemCount: state.expenses.length,
                    itemBuilder: (context, index) {
                      final expense = state.expenses[index];
                      return FadeInUp(
                        delay: Duration(milliseconds: 100 * index),
                        child: _RecurrentExpenseCard(
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
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
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
        title: Text(
          expense.name,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: expense.isActive ? colorScheme.onSurface : colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        subtitle: Text(
          expense.day != null ? 'Día ${expense.day} de cada mes' : 'Sin día fijo de cobro',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '-${humanizeNumbers.number(expense.amount)}€',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: expense.isActive ? Colors.red.shade400 : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => context.read<RecurrentExpensesCubit>().toggleActive(expense),
                  child: Icon(
                    expense.isActive ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                    color: Colors.orange.withValues(alpha: 0.6),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => AddEditRecurrentExpenseDialog(expense: expense),
                    );
                  },
                  child: Icon(
                    Icons.edit_rounded,
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
  const _EmptyState({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInDown(
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Opacity(
                opacity: 0.2,
                child: Image.asset('assets/Logo.png', height: 80, fit: BoxFit.contain),
              ),
            ),
          ),
          const SizedBox(height: 30),
          FadeIn(
            delay: const Duration(milliseconds: 400),
            child: Text(
              'SIN GASTOS FIJOS',
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
                'Añade tus suscripciones o facturas mensuales para que la app las anote automáticamente por ti.',
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
    );
  }
}
