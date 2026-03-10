import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/presentation/bloc/debts_loans_cubit/debts_loans_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/debts_loans_dialogs/add_debt_loan_payment_dialog.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/debts_loans_dialogs/add_edit_debt_loan_dialog.dart';
import 'package:ahorrapp/presentation/widgets/shared/swipe_background_widget.dart';
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
    final double progress = item.totalAmount > 0 ? item.paidAmount / item.totalAmount : 0;
    final bool isFullyPaid = item.remainingAmount <= 0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.orange.withValues(alpha: 0.15),
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
                contentPadding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isDebt ? Icons.money_off_rounded : Icons.handshake_rounded,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                title: Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: isDebt ? "A: " : "De: ",
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextSpan(
                            text: item.person,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (item.dueDate != null)
                      Text(
                        'Vence: ${DateFormat('dd/MM/yyyy').format(item.dueDate!)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (isFullyPaid)
                          const Text(
                            'Pagada',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              color: Colors.green,
                            ),
                          )
                        else
                          Text(
                            '${isDebt ? "-" : "+"}${humanizeNumbers.number(item.remainingAmount)}€',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: isDebt ? Colors.red.shade400 : Colors.green.shade400,
                            ),
                          ),
                        if (item.isInstallment && !isFullyPaid)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              '${humanizeNumbers.number(item.installmentAmount ?? 0)}€/mes',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    if (!item.isCompleted)
                      IconButton(
                        onPressed: () => _showPaymentDialog(context),
                        icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.orange, size: 28),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pagado: ${humanizeNumbers.number(item.paidAmount)}€',
                          style: TextStyle(fontSize: 10, color: colorScheme.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Total: ${humanizeNumbers.number(item.totalAmount)}€',
                          style: TextStyle(fontSize: 10, color: colorScheme.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Colors.orange.withValues(alpha: 0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress >= 1.0 ? Colors.green.shade400 : Colors.orange.withValues(alpha: 0.4)
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Eliminar registro?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('¿Estás seguro de que quieres eliminar "${item.name}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              context.read<DebtsLoansCubit>().deleteDebtLoan(item.id);
              Navigator.pop(context, true);
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
