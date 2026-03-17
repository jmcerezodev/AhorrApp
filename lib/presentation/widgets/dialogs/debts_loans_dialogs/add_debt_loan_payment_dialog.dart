import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/presentation/bloc/debts_loans_cubit/debts_loans_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/app_dialogs.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/custom_dialog_wrapper.dart';
import 'package:ahorrapp/presentation/widgets/inputs/inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AddDebtLoanPaymentDialog extends StatefulWidget {
  final DebtLoan item;

  const AddDebtLoanPaymentDialog({
    super.key,
    required this.item,
  });

  @override
  State<AddDebtLoanPaymentDialog> createState() => _AddDebtLoanPaymentDialogState();
}

class _AddDebtLoanPaymentDialogState extends State<AddDebtLoanPaymentDialog> {
  late TextEditingController _amountController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final suggested = widget.item.isInstallment 
        ? (widget.item.installmentAmount ?? widget.item.remainingAmount)
        : widget.item.remainingAmount;
    
    _amountController = TextEditingController(text: HumanizeNumbers().format(suggested));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDebt = widget.item.type == DebtLoanType.debt;
    final humanizeNumbers = HumanizeNumbers();

    return CustomDialogWrapper(
      borderColor: Colors.orange.withValues(alpha: isDark ? 0.2 : 0.4),
      horizontalInsetPadding: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDialogs.dialogRowHeader(
            icon: Icons.add_card_rounded,
            title: isDebt ? 'REGISTRAR PAGO' : 'REGISTRAR COBRO',
            color: Colors.orange,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 20),
          Text(
            widget.item.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            'Pendiente: ${humanizeNumbers.number(widget.item.remainingAmount)}€',
            style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 25),
          CustomInputTextWidget(
            controller: _amountController,
            label: isDebt ? 'Importe a pagar' : 'Importe a cobrar',
            hintText: '0.00',
            enabled: !_isLoading,
            autoFocus: true,
            textInputType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 35),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _isLoading ? null : () => context.pop(),
                  child: Text('CANCELAR', 
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.4), 
                      fontWeight: FontWeight.bold
                    )
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: AppDialogs.dialogPrimaryButton(
                  text: 'CONFIRMAR',
                  color: Colors.orange,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _onConfirm,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onConfirm() async {
    final amount = HumanizeNumbers().parse(_amountController.text.trim());

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, introduce un importe válido'))
      );
      return;
    }

    if (!widget.item.isInstallment) {
      _showAddToHistoryConfirmation(amount);
    } else {
      _processPayment(amount, false);
    }
  }

  void _showAddToHistoryConfirmation(double amount) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDebt = widget.item.type == DebtLoanType.debt;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDialogWrapper(
        borderColor: Colors.orange.withValues(alpha: isDark ? 0.2 : 0.4),
        horizontalInsetPadding: 20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppDialogs.dialogHeader(
              icon: Icons.history_edu_rounded,
              title: '¿AÑADIR AL HISTORIAL?',
              color: Colors.orange,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 15),
            Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withValues(alpha: 0.6), height: 1.5),
                children: [
                  const TextSpan(text: '¿Deseas registrar este '),
                  TextSpan(
                    text: isDebt ? "pago como un gasto" : "cobro como un ingreso",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)
                  ),
                  const TextSpan(text: ' en la '),
                  const TextSpan(text: 'pantalla principal', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  const TextSpan(text: '?'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _processPayment(amount, false);
                    },
                    child: Text('NO, SOLO DEUDA', 
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.4), 
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      )
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppDialogs.dialogPrimaryButton(
                    text: 'SÍ, AÑADIR',
                    color: Colors.orange,
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _processPayment(amount, true);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment(double amount, bool addToHistory) async {
    setState(() => _isLoading = true);
    
    final bool isCompleting = (widget.item.paidAmount + amount) >= widget.item.totalAmount;
    final debtsCubit = context.read<DebtsLoansCubit>();
    
    await debtsCubit.addPayment(
      widget.item.id, 
      amount, 
      addToHistory: addToHistory
    );
    
    if (mounted) {
      context.pop(); 
      
      if (isCompleting) {
        _showCompletionDialog(context);
      }
    }
  }

  void _showCompletionDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final debtsCubit = context.read<DebtsLoansCubit>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomDialogWrapper(
        borderColor: Colors.green.withValues(alpha: isDark ? 0.2 : 0.4),
        horizontalInsetPadding: 20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppDialogs.dialogRowHeader(
              icon: Icons.check_circle_rounded,
              title: 'CUENTA SALDADA',
              color: Colors.green,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 25),
            Text(
              '¡Felicidades!',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.w900, 
                color: isDark ? Colors.white : colorScheme.onSurface
              ),
            ),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withValues(alpha: 0.7), height: 1.5),
                children: [
                  const TextSpan(text: 'Has completado el pago de '),
                  TextSpan(text: '"${widget.item.name}"', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  const TextSpan(text: '. ¿Deseas '),
                  const TextSpan(text: 'eliminar', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  const TextSpan(text: ' este registro de la lista o mantenerlo como completado?'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 35),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text('MANTENER', 
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.4), 
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: AppDialogs.dialogPrimaryButton(
                    text: 'ELIMINAR',
                    color: Colors.orange,
                    onPressed: () {
                      debtsCubit.deleteDebtLoan(widget.item.id);
                      Navigator.pop(dialogContext);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
