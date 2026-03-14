import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/debts_loans_dialogs/add_edit_debt_loan_dialog.dart';
import 'package:ahorrapp/presentation/widgets/widgets.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DebtsSummaryWidget extends StatelessWidget {
  final double totalAmount;
  final bool isDebtView;

  const DebtsSummaryWidget({
    super.key, 
    required this.totalAmount, 
    required this.isDebtView
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final humanizeNumbers = HumanizeNumbers();
    final colorScheme = Theme.of(context).colorScheme;
    final isPrivacyActive = context.watch<ThemeCubit>().state.isPrivacyModeActive;

    return FadeInDown(
      duration: const Duration(milliseconds: 600),
      from: 100, // Unificado a 100px
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            gradient: isDark 
              ? const LinearGradient(
                  colors: [Color(0xFF2C2C2C), Color(0xFF1E1E1E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.orange.withValues(alpha: isDark ? 0.1 : 0.3), 
              width: 1.5
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // COLUMNA 1: INFO Y CONTROL
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isDebtView ? 'TOTAL QUE DEBES' : 'TOTAL QUE TE DEBEN',
                            style: TextStyle(
                              color: Colors.orange.shade400,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => context.read<ThemeCubit>().togglePrivacyMode(),
                            child: Icon(
                              isPrivacyActive ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              size: 14,
                              color: Colors.orange.shade400.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: PrivacyAmountText(
                          amount: '${humanizeNumbers.number(totalAmount, isPrivacyModeActive: isPrivacyActive)}€',
                          isPrivacyActive: isPrivacyActive,
                          style: TextStyle(
                            color: isDark ? Colors.white : colorScheme.onSurface,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      _StatusChip(
                        isDebtView: isDebtView,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 15),

                // COLUMNA 2: BURBUJA DE ACCIÓN
                BurbujaResumenWidget(isDebtView: isDebtView),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BurbujaResumenWidget extends StatelessWidget {
  final bool isDebtView;
  const BurbujaResumenWidget({super.key, required this.isDebtView});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AddEditDebtLoanDialog(
            initialType: isDebtView ? DebtLoanType.debt : DebtLoanType.loan,
          ),
        );
      },
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.orange.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_box_rounded,
              color: Colors.orange,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              isDebtView ? 'NUEVA DEUDA' : 'NUEVO PRÉSTAMO',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                color: Colors.orange,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isDebtView;
  final bool isDark;

  const _StatusChip({
    required this.isDebtView, 
    required this.isDark
  });

  @override
  Widget build(BuildContext context) {
    final color = Colors.orange.shade400;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDebtView ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, 
            color: color.withValues(alpha: 0.8), 
            size: 12
          ),
          const SizedBox(width: 6),
          Text(
            isDebtView ? 'PENDIENTE DE PAGO' : 'PENDIENTE DE COBRO',
            style: TextStyle(
              color: isDark ? Colors.white70 : colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
