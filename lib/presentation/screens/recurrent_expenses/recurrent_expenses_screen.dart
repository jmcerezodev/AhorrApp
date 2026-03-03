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
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 20, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
      padding: const EdgeInsets.only(bottom: 15),
      child: Dismissible(
        key: Key(expense.id),
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

    return Container(
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
                if (isAutomatic && expense.isActive) ...[
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
                      // El diálogo ahora maneja internamente la lógica y el éxito
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
          if (isAutomatic && expense.isActive)
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
