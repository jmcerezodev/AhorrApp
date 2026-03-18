import 'package:ahorrapp/core/config/responsive_utils.dart';
import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/debts_loans_dialogs/add_debt_loan_payment_dialog.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/debts_loans_dialogs/add_edit_debt_loan_dialog.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/debts_loans_dialogs/delete_debt_loan_dialog.dart';
import 'package:ahorrapp/presentation/widgets/shared/swipe_background_widget.dart';
import 'package:ahorrapp/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class DebtLoanCard extends StatelessWidget {
  final DebtLoan item;
  final bool isDark;
  final ColorScheme colorScheme;

  const DebtLoanCard({
    super.key,
    required this.item,
    required this.isDark,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final humanizeNumbers = HumanizeNumbers();
    final bool isDebt = item.type == DebtLoanType.debt;
    final isPrivacyActive = context.watch<ThemeCubit>().state.isPrivacyModeActive;
    final bool isSmallScreen = MediaQuery.of(context).size.width <= 375;
    
    final double progress = item.totalAmount > 0 ? item.paidAmount / item.totalAmount : 0;
    final bool isFullyPaid = item.remainingAmount <= 0;
    
    // Vincular con Gasto Recurrente si existe
    final recurrentState = context.watch<RecurrentExpensesCubit>().state;
    RecurrentExpense? linkedExpense;
    if (item.recurrentExpenseId != null) {
      try {
        linkedExpense = recurrentState.expenses.firstWhere((e) => e.id == item.recurrentExpenseId);
      } catch (_) {}
    }

    final bool isAutomated = linkedExpense != null;
    final bool isPaused = isAutomated && !linkedExpense.isActive;

    // Lógica para calcular cuotas
    int installmentsPaid = 0;
    if (item.isInstallment && item.installmentAmount != null && item.installmentAmount! > 0) {
      installmentsPaid = (item.paidAmount / item.installmentAmount!).floor();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Dismissible(
        key: Key('debt_loan_${item.id}'),
        direction: DismissDirection.horizontal,
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            _showEditDialog(context);
            return false;
          } else {
            return await _showDeleteConfirmation(context);
          }
        },
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
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(25.w),
            border: Border.all(
              color: isPaused
                ? Colors.grey.withValues(alpha: 0.2)
                : Colors.orange.withValues(alpha: isAutomated ? 0.3 : 0.15),
              width: 1.2.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10.w,
                offset: Offset(0, 5.h),
              )
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  (isSmallScreen ? 12 : 20).w,
                  10.h,
                  10.w,
                  10.h,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Leading
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: (isPaused ? Colors.grey : Colors.orange).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDebt ? Icons.money_off_rounded : Icons.handshake_rounded,
                        color: isPaused ? Colors.grey : Colors.orange,
                        size: 24.w,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Title + Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14.sp,
                              color: isPaused ? colorScheme.onSurface.withValues(alpha: 0.5) : colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: isDebt ? "A: " : "De: ",
                                  style: TextStyle(
                                    color: isPaused ? Colors.grey : Colors.orange,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 11.sp,
                                  ),
                                ),
                                TextSpan(
                                  text: item.person,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface.withValues(alpha: isPaused ? 0.3 : 0.6),
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (isAutomated)
                            Padding(
                              padding: EdgeInsets.only(top: 2.h),
                              child: Text(
                                isPaused
                                  ? 'Pausado'
                                  : (linkedExpense.nextPaymentDate != null
                                      ? 'Próximo: ${DateFormat("d MMM", "es_ES").format(linkedExpense.nextPaymentDate!)}'
                                      : 'Sin fecha'),
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w800,
                                  color: isPaused ? Colors.grey : Colors.orange.withValues(alpha: 0.7),
                                ),
                              ),
                            )
                          else if (item.isInstallment && item.totalInstallments != null)
                            Padding(
                              padding: EdgeInsets.only(top: 2.h),
                              child: Text(
                                'Cuota $installmentsPaid de ${item.totalInstallments}',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: (isPaused ? Colors.grey : Colors.orange).withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // Trailing Column
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (isFullyPaid)
                          Text(
                            'Finalizado',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13.sp,
                              color: Colors.green,
                            ),
                          )
                        else
                          PrivacyAmountText(
                            amount: '${humanizeNumbers.number(item.remainingAmount, isPrivacyModeActive: isPrivacyActive)}€',
                            isPrivacyActive: isPrivacyActive,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15.sp,
                              color: isPaused
                                ? Colors.grey
                                : (isDebt ? Colors.red.shade400 : Colors.blue.shade400),
                            ),
                          ),
                        if (item.isInstallment && !isFullyPaid) ...[
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                            decoration: BoxDecoration(
                              color: (isPaused ? Colors.grey : Colors.orange).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4.w),
                            ),
                            child: PrivacyAmountText(
                              amount: '${humanizeNumbers.number(item.installmentAmount ?? 0, isPrivacyModeActive: isPrivacyActive)}€/mes',
                              isPrivacyActive: isPrivacyActive,
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w800,
                                color: isPaused ? Colors.grey : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                        if (isAutomated) ...[
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                            decoration: BoxDecoration(
                              color: (isPaused ? Colors.grey : Colors.orange).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(5.w),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isPaused ? Icons.pause_circle_filled_rounded : Icons.bolt_rounded,
                                  size: 10.sp,
                                  color: isPaused ? Colors.grey : Colors.orange,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  isPaused ? 'PAUSA' : 'AUTO',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w900,
                                    color: isPaused ? Colors.grey : Colors.orange,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (!item.isCompleted && !item.isInstallment && !isAutomated) ...[
                          SizedBox(height: 4.h),
                          IconButton(
                            onPressed: () => _showPaymentDialog(context),
                            icon: Icon(Icons.add_circle_outline_rounded, color: Colors.orange, size: 26.w),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
                  
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      (isSmallScreen ? 12 : 20).w, 
                      0, 
                      (isSmallScreen ? 12 : 20).w, 
                      15.h
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            PrivacyAmountText(
                              amount: 'Pagado: ${humanizeNumbers.number(item.paidAmount, isPrivacyModeActive: isPrivacyActive)}€',
                              isPrivacyActive: isPrivacyActive,
                              style: TextStyle(fontSize: 10.sp, color: colorScheme.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.bold),
                            ),
                            if (item.dueDate != null && !isAutomated)
                              Padding(
                                padding: EdgeInsets.only(bottom: 2.h),
                                child: Text(
                                  'Vence: ${DateFormat('dd/MM/yyyy').format(item.dueDate!)}',
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    color: Colors.orange.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            PrivacyAmountText(
                              amount: 'Total: ${humanizeNumbers.number(item.totalAmount, isPrivacyModeActive: isPrivacyActive)}€',
                              isPrivacyActive: isPrivacyActive,
                              style: TextStyle(fontSize: 10.sp, color: colorScheme.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.w),
                          child: LinearProgressIndicator(
                            value: isPrivacyActive ? 0.0 : progress,
                            minHeight: 6.h,
                            backgroundColor: (isPaused ? Colors.grey : Colors.orange).withValues(alpha: 0.05),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isPaused 
                                ? Colors.grey.withValues(alpha: 0.3)
                                : (progress >= 1.0 ? Colors.green.shade400 : Colors.orange.withValues(alpha: 0.4))
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddEditDebtLoanDialog(
        item: item,
        initialType: item.type,
      ),
    );
  }

  void _showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddDebtLoanPaymentDialog(item: item),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => DeleteDebtLoanDialog(item: item),
    );
    return result ?? false;
  }
}
