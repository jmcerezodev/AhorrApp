import 'package:ahorrapp/core/config/responsive_utils.dart';
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

    final debtsState = context.read<DebtsLoansCubit>().state;
    DebtLoan? linkedItem;
    try {
      linkedItem = debtsState.debtsLoans.firstWhere((d) => d.recurrentExpenseId == expenseId);
    } catch (_) {}

    final bool isLinked = linkedItem != null;
    final bool isLoan = isLinked && linkedItem.type == DebtLoanType.loan;
    
    final expenseState = context.read<RecurrentExpensesCubit>().state;
    bool isIncome = false;
    try {
      isIncome = expenseState.expenses.firstWhere((e) => e.id == expenseId).isIncome;
    } catch (_) {}

    return CustomDialogWrapper(
      borderColor: Colors.red.shade400.withValues(alpha: isDark ? 0.2 : 0.4),
      horizontalInsetPadding: 30.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDialogs.dialogHeader(
            icon: Icons.delete_outline_rounded, 
            color: Colors.red.shade400, 
            title: isIncome ? '¿Eliminar Ingreso Fijo?' : '¿Eliminar Gasto Fijo?',
            colorScheme: colorScheme,
          ),
          SizedBox(height: 20.h),
          
          AppDialogs.dialogMessage(
            '¿Estás seguro de que quieres eliminar este registro automático?',
            colorScheme,
          ),
          SizedBox(height: 10.h),
          Text(
            '"$expenseName"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
            ),
          ),
          
          if (isLinked) ...[
            SizedBox(height: 15.h),
            AppDialogs.dialogMessage(
              'Este registro está vinculado ${isLoan ? "al préstamo" : "a la deuda"} "${linkedItem.name}". Si lo eliminas, también se borrará de tu lista de cuentas pendientes.',
              colorScheme,
              customColor: Colors.orange.shade700,
            ),
          ],
          
          SizedBox(height: 15.h),
          AppDialogs.dialogMessage(
            'Esta acción no se puede deshacer.',
            colorScheme,
            customColor: Colors.red.shade400.withValues(alpha: 0.8),
          ),
          SizedBox(height: 30.h),

          // Usamos OverflowBar para que los botones se apilen si no caben
          OverflowBar(
            spacing: 15.w,
            overflowSpacing: 10.h,
            alignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 130.w, // Ancho controlado para que quepan dos en iPhone 7
                child: AppDialogs.dialogSecondaryButton(
                  text: 'CANCELAR', 
                  onPressed: () => Navigator.of(context).pop(false),
                  colorScheme: colorScheme,
                ),
              ),
              SizedBox(
                width: 130.w,
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
