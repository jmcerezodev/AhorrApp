import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/presentation/bloc/debts_loans_cubit/debts_loans_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DeleteDebtLoanDialog extends StatelessWidget {
  final DebtLoan item;

  const DeleteDebtLoanDialog({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDebt = item.type == DebtLoanType.debt;
    final bool hasRecurrent = item.recurrentExpenseId != null && item.recurrentExpenseId!.isNotEmpty;

    return CustomDialogWrapper(
      borderColor: Colors.red.shade400.withValues(alpha: isDark ? 0.2 : 0.4),
      horizontalInsetPadding: 30,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDialogs.dialogHeader(
            icon: Icons.delete_outline_rounded,
            color: Colors.red.shade400,
            title: isDebt ? '¿ELIMINAR DEUDA?' : '¿ELIMINAR PRÉSTAMO?',
            circularBackground: true,
            iconSize: 32,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 15),
          AppDialogs.dialogMessage(
            hasRecurrent
              ? 'Esta deuda está vinculada a un pago fijo automático. Si la eliminas, también se borrará de tu lista de Gastos Fijos. ¿Deseas continuar?'
              : '¿Estás seguro de que quieres eliminar "${item.name}"? Esta acción no se puede deshacer.',
            colorScheme,
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
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: AppDialogs.dialogPrimaryButton(
                  text: 'ELIMINAR',
                  onPressed: () {
                    context.read<DebtsLoansCubit>().deleteDebtLoan(
                      item.id, 
                      deleteRecurrent: true // Siempre borrar el recurrente si existe el vínculo
                    );
                    context.pop(true);
                  },
                  color: Colors.red.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
