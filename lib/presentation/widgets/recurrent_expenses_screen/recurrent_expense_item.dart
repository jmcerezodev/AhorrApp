import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/dialogs.dart';
import 'package:ahorrapp/presentation/widgets/shared/swipe_background_widget.dart';
import 'package:ahorrapp/presentation/widgets/recurrent_expenses_screen/recurrent_expense_card.dart';
import 'package:flutter/material.dart';

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
        child: RecurrentExpenseCard(
          expense: expense,
          humanizeNumbers: humanizeNumbers,
          colorScheme: colorScheme,
          isDark: isDark,
        ),
      ),
    );
  }
}
