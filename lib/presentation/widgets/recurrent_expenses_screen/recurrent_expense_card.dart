import 'package:ahorrapp/core/config/responsive_utils.dart';
import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/recurrent_expenses_dialogs/confirm_manual_payment_dialog.dart';
import 'package:ahorrapp/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class RecurrentExpenseCard extends StatelessWidget {
  final RecurrentExpense expense;
  final HumanizeNumbers humanizeNumbers;
  final ColorScheme colorScheme;
  final bool isDark;

  const RecurrentExpenseCard({
    super.key,
    required this.expense,
    required this.humanizeNumbers,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAutomatic = expense.day != null;
    final DateTime? nextPaymentDate = expense.nextPaymentDate;
    final now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final int daysRemaining = nextPaymentDate?.difference(now).inDays ?? 0;
    final double progress = expense.cycleProgress;
    final bool isPaused = isAutomatic && !expense.isActive;
    final bool showProgress = isAutomatic && expense.isActive;
    final isPrivacyActive = context.watch<ThemeCubit>().state.isPrivacyModeActive;
    final bool isSmallScreen = MediaQuery.of(context).size.width <= 375;

    final debtsState = context.watch<DebtsLoansCubit>().state;
    DebtLoan? linkedItem;
    try {
      linkedItem = debtsState.debtsLoans.firstWhere((d) => d.recurrentExpenseId == expense.id);
    } catch (_) {}

    final bool isLinked = linkedItem != null;
    final bool isLoan = isLinked && linkedItem.type == DebtLoanType.loan;
    final bool isIncome = expense.isIncome;
    
    final String displayTitle = isLinked ? linkedItem.name : expense.name;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(25.w),
        border: Border.all(
          color: Colors.orange.withValues(alpha: expense.isActive ? 0.15 : 0.05),
          width: 1.2,
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
          Row(
            children: [
              // LEADING: Icono
              Stack(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconForCategory(expense.category),
                      color: expense.isActive ? Colors.orange : Colors.grey,
                      size: 22.sp,
                    ),
                  ),
                  if (isAutomatic)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          color: expense.isActive ? Colors.green.shade400 : Colors.grey.shade400,
                          shape: BoxShape.circle,
                          border: Border.all(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, width: 2.w),
                        ),
                      ),
                    ),
                ],
              ),
              
              SizedBox(width: 12.w),

              // CENTRAL: Título y Subtítulo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.sp,
                        color: expense.isActive ? colorScheme.onSurface : colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                    Text(
                      _getSubtitleText(),
                      style: TextStyle(
                        fontSize: isSmallScreen ? 9.sp : 10.sp,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              // TRAILING: Monto y Acción
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PrivacyAmountText(
                    amount: '${isIncome ? "+" : "-"}${humanizeNumbers.number(expense.amount, isPrivacyModeActive: isPrivacyActive)}€',
                    isPrivacyActive: isPrivacyActive,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15.sp,
                      color: expense.isActive 
                        ? (isIncome ? Colors.green.shade400 : Colors.red.shade400)
                        : Colors.grey,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  GestureDetector(
                    onTap: () async {
                      if (isAutomatic) {
                        context.read<RecurrentExpensesCubit>().toggleActive(expense);
                      } else {
                        await showDialog<bool>(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => ConfirmManualPaymentDialog(
                            expense: expense,
                            amount: humanizeNumbers.number(expense.amount, isPrivacyModeActive: isPrivacyActive),
                          ),
                        );
                      }
                    },
                    child: Icon(
                      isAutomatic 
                        ? (expense.isActive ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded)
                        : (isIncome ? Icons.add_circle_rounded : Icons.add_circle_outline_rounded),
                      color: Colors.orange.withValues(alpha: 0.6),
                      size: 28.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // BARRA DE PROGRESO E INFO INFERIOR
          if (showProgress || isPaused || isLinked || !isAutomatic) ...[
            SizedBox(height: 8.h),
            if (showProgress)
              ClipRRect(
                borderRadius: BorderRadius.circular(10.w),
                child: LinearProgressIndicator(
                  value: isPrivacyActive ? 0.0 : progress,
                  minHeight: 3.h,
                  backgroundColor: Colors.orange.withValues(alpha: 0.05),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.withValues(alpha: 0.4)),
                ),
              ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isAutomatic)
                        Flexible(
                          child: Text(
                            isPaused
                              ? 'PAUSADO'
                              : (daysRemaining <= 0
                                  ? (isIncome ? '¡Hoy ingresa!' : '¡Hoy se cobra!')
                                  : (isIncome ? 'Próximo ingreso en $daysRemaining días' : 'Próximo cobro en $daysRemaining días')),
                            style: TextStyle(
                              fontSize: 8.5.sp,
                              fontWeight: FontWeight.w800,
                              color: isPaused
                                ? Colors.grey.shade500
                                : (daysRemaining <= 3 ? Colors.red.shade300 : Colors.orange.withValues(alpha: 0.6)),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      if (!isAutomatic)
                        Text(
                          isIncome ? 'INGRESO MANUAL' : 'COBRO MANUAL',
                          style: TextStyle(
                            fontSize: 8.5.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.blueGrey.shade300,
                            letterSpacing: 0.3,
                          ),
                        ),
                      SizedBox(width: 8.w),
                      _CategoryChip(category: expense.category),
                    ],
                  ),
                ),
                if (isLinked) ...[
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6.w),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      isLoan ? 'PRÉSTAMO' : 'DEUDA',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 7.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getSubtitleText() {
    if (expense.day == null) {
      return expense.isIncome ? 'Ingreso manual' : 'Cobro manual';
    }

    if (expense.frequency == RecurrentFrequency.monthly) {
      return 'Día ${expense.day} de cada mes';
    }

    // Para frecuencias largas: mostrar la fecha real del próximo cobro
    final next = expense.nextPaymentDate;
    if (next == null) return 'Día ${expense.day}';

    final String monthName = DateFormat('MMMM', 'es_ES').format(next);
    final String capitalizedMonth =
        monthName[0].toUpperCase() + monthName.substring(1);

    final String freqLabel;
    switch (expense.frequency) {
      case RecurrentFrequency.quarterly:   freqLabel = 'trimestre'; break;
      case RecurrentFrequency.semiAnnually: freqLabel = '6 meses';  break;
      case RecurrentFrequency.annually:    freqLabel = 'año';       break;
      default: freqLabel = 'periodo';
    }

    return '${next.day} de $capitalizedMonth (cada $freqLabel)';
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'hogar': return Icons.home_work_rounded;
      case 'suscripción': return Icons.subscriptions_rounded;
      case 'salud': return Icons.favorite_rounded;
      case 'transporte': return Icons.directions_car_rounded;
      case 'ocio': return Icons.sports_esports_rounded;
      default: return Icons.receipt_long_rounded;
    }
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;

  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.w),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Text(
        category.toUpperCase(),
        style: TextStyle(
          color: Colors.orange,
          fontSize: 7.sp,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
