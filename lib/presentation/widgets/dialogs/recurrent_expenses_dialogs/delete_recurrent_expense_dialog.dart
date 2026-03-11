import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeleteRecurrentExpenseDialog extends StatelessWidget {
  final String expenseId;
  final String expenseName;

  const DeleteRecurrentExpenseDialog({
    super.key,
    required this.expenseId,
    required this.expenseName,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Buscamos si hay un registro vinculado (deuda o préstamo)
    final debtsState = context.read<DebtsLoansCubit>().state;
    DebtLoan? linkedItem;
    try {
      linkedItem = debtsState.debtsLoans.firstWhere((d) => d.recurrentExpenseId == expenseId);
    } catch (_) {}

    final bool isLinked = linkedItem != null;
    final bool isLoan = isLinked && linkedItem.type == DebtLoanType.loan;
    
    // Determinamos si el registro actual es un ingreso o un gasto fijo
    final expenseState = context.read<RecurrentExpensesCubit>().state;
    bool isIncome = false;
    try {
      isIncome = expenseState.expenses.firstWhere((e) => e.id == expenseId).isIncome;
    } catch (_) {}

    return CustomDialogWrapper(
      borderColor: Colors.red.shade400.withValues(alpha: isDark ? 0.2 : 0.4),
      horizontalInsetPadding: 30,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDialogs.dialogHeader(
            icon: Icons.delete_outline_rounded, 
            color: Colors.red.shade400, 
            title: isIncome ? '¿ELIMINAR INGRESO FIJO?' : '¿ELIMINAR GASTO FIJO?',
            circularBackground: true,
            iconSize: 32,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 15),
          
          Text.rich(
            TextSpan(
              style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withValues(alpha: 0.5), height: 1.5),
              children: [
                TextSpan(text: '¿Estás seguro de que quieres eliminar este ${isIncome ? "ingreso" : "gasto"} '),
                TextSpan(text: '"$expenseName"', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                const TextSpan(text: '? '),
                if (isLinked) ...[
                  TextSpan(text: 'Este ${isIncome ? "ingreso" : "gasto"} está vinculado ${isLoan ? "al préstamo" : "a la deuda"} '),
                  TextSpan(text: '"${linkedItem.name}"', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  TextSpan(text: '. Si lo eliminas, ${isLoan ? "el préstamo" : "la deuda"} también se '),
                  const TextSpan(text: 'borrará de tu lista.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                ] else ...[
                  const TextSpan(text: 'Esta acción eliminará la automatización y '),
                  const TextSpan(text: 'no se puede deshacer.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                ],
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                  child: Text(
                    'CANCELAR', 
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.4), 
                      fontWeight: FontWeight.bold, 
                      letterSpacing: 1
                    )
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: AppDialogs.dialogPrimaryButton(
                  text: 'ELIMINAR', 
                  onPressed: () {
                    final debtsCubit = context.read<DebtsLoansCubit>();
                    context.read<RecurrentExpensesCubit>().deleteExpense(
                      expenseId, 
                      debtsCubit: debtsCubit,
                      deleteDebt: isLinked
                    );
                    Navigator.of(context).pop(true);
                  }, 
                  color: Colors.red.shade400
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
