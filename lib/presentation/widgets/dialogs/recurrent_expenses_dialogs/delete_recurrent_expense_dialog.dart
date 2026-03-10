import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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

    // Buscamos si es una deuda vinculada
    final debtsState = context.read<DebtsLoansCubit>().state;
    DebtLoan? linkedDebt;
    try {
      linkedDebt = debtsState.debtsLoans.firstWhere((d) => d.recurrentExpenseId == expenseId);
    } catch (_) {}

    final bool isLinked = linkedDebt != null;

    return CustomDialogWrapper(
      borderColor: Colors.red.shade400.withValues(alpha: isDark ? 0.2 : 0.4),
      horizontalInsetPadding: 30,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDialogs.dialogHeader(
            icon: Icons.delete_outline_rounded, 
            color: Colors.red.shade400, 
            title: '¿ELIMINAR GASTO FIJO?',
            circularBackground: true,
            iconSize: 32,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 15),
          
          AppDialogs.dialogMessage(
            isLinked 
              ? 'Este pago fijo está vinculado a la deuda "${linkedDebt.name}". Si lo eliminas, la deuda también se borrará de tu lista. ¿Estás seguro?'
              : 'Estás a punto de borrar "$expenseName". Esta acción eliminará la automatización y no se puede deshacer.', 
            colorScheme
          ),
          const SizedBox(height: 30),

          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => context.pop(false),
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
                      deleteDebt: isLinked // Si está vinculada, borramos la deuda también
                    );
                    context.pop(true);
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
