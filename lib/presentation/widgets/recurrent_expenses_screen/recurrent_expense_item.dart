import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:ahorrapp/presentation/bloc/debts_loans_cubit/debts_loans_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/dialogs.dart';
import 'package:ahorrapp/presentation/widgets/shared/swipe_background_widget.dart';
import 'package:ahorrapp/presentation/widgets/recurrent_expenses_screen/recurrent_expense_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecurrentExpenseItem extends StatelessWidget {
  final RecurrentExpense expense;
  final int index;
  final HumanizeNumbers humanizeNumbers;
  final ColorScheme colorScheme;
  final bool isDark;

  const RecurrentExpenseItem({
    super.key,
    required this.expense,
    required this.index,
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
            _onEdit(context);
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
        child: RecurrentExpenseCard(
          expense: expense,
          humanizeNumbers: humanizeNumbers,
          colorScheme: colorScheme,
          isDark: isDark,
        ),
      ),
    );
  }

  void _onEdit(BuildContext context) {
    // Buscamos si hay una deuda vinculada a este gasto recurrente
    final debtsState = context.read<DebtsLoansCubit>().state;
    DebtLoan? linkedDebt;
    
    try {
      linkedDebt = debtsState.debtsLoans.firstWhere(
        (d) => d.recurrentExpenseId == expense.id
      );
    } catch (_) {
      linkedDebt = null;
    }

    if (linkedDebt != null) {
      // Si hay deuda vinculada, abrimos el diálogo de deudas
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AddEditDebtLoanDialog(
          item: linkedDebt,
          initialType: linkedDebt!.type,
        ),
      );
    } else {
      // Si es un gasto normal, abrimos el diálogo de gastos recurrentes
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AddEditRecurrentExpenseDialog(
          expense: expense,
          isIncome: expense.isIncome, // PASAMOS EL TIPO CORRECTO
        ),
      );
    }
  }
}
