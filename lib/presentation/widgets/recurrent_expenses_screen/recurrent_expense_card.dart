import 'package:ahorrapp/core/config/responsive_utils.dart';
import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/domain/entities/debt_loan.dart';
import 'package:ahorrapp/domain/entities/recurrent_expense.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/recurrent_expenses_dialogs/confirm_manual_payment_dialog.dart';
import 'package:ahorrapp/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    final DateTime nextPaymentDate = _calculateNextPaymentDate();
    final int daysRemaining = nextPaymentDate.difference(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)).inDays;
    final double progress = _calculateProgress(nextPaymentDate);
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
                    amount: '${isIncome ? "+" : "-"}${humanizeNumbers.number(expense.amount.toInt().toDouble(), isPrivacyModeActive: isPrivacyActive)}€',
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
                            amount: humanizeNumbers.number(expense.amount.toInt().toDouble(), isPrivacyModeActive: isPrivacyActive),
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
          if (showProgress || isLinked) ...[
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
                if (showProgress)
                  Expanded(
                    child: Text(
                      daysRemaining == 0 
                        ? (isIncome ? '¡Hoy ingresa!' : '¡Hoy se cobra!')
                        : (isIncome ? 'Próximo ingreso en $daysRemaining días' : 'Próximo cobro en $daysRemaining días'),
                      style: TextStyle(
                        fontSize: 8.5.sp,
                        fontWeight: FontWeight.w800,
                        color: daysRemaining <= 3 ? Colors.red.shade300 : Colors.orange.withValues(alpha: 0.6),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                if (isLinked) ...[
                  if (showProgress) SizedBox(width: 8.w),
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

  DateTime _calculateNextPaymentDate() {
    final now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime nextDate = DateTime(expense.startDate.year, expense.startDate.month, expense.day ?? expense.startDate.day);
    
    int monthsToAdd = 0;
    switch (expense.frequency) {
      case RecurrentFrequency.monthly: monthsToAdd = 1; break;
      case RecurrentFrequency.quarterly: monthsToAdd = 3; break;
      case RecurrentFrequency.semiAnnually: monthsToAdd = 6; break;
      case RecurrentFrequency.annually: monthsToAdd = 12; break;
    }

    if (nextDate.isAfter(now) || nextDate.isAtSameMomentAs(now)) {
      return nextDate;
    }

    while (nextDate.isBefore(now)) {
      nextDate = DateTime(nextDate.year, nextDate.month + monthsToAdd, nextDate.day);
    }
    
    return nextDate;
  }

  double _calculateProgress(DateTime nextDate) {
    final now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    
    int monthsInCycle = 1;
    switch (expense.frequency) {
      case RecurrentFrequency.monthly: monthsInCycle = 1; break;
      case RecurrentFrequency.quarterly: monthsInCycle = 3; break;
      case RecurrentFrequency.semiAnnually: monthsInCycle = 6; break;
      case RecurrentFrequency.annually: monthsInCycle = 12; break;
    }

    final prevDate = DateTime(nextDate.year, nextDate.month - monthsInCycle, nextDate.day);
    
    final totalDays = nextDate.difference(prevDate).inDays;
    final elapsedDays = now.difference(prevDate).inDays;

    if (totalDays <= 0) return 0.0;
    return (elapsedDays / totalDays).clamp(0.0, 1.0);
  }

  String _getSubtitleText() {
    final bool isIncome = expense.isIncome;
    if (expense.day == null) return isIncome ? 'Ingreso manual' : 'Cobro manual';

    switch (expense.frequency) {
      case RecurrentFrequency.monthly:
        return 'Día ${expense.day} de cada mes';
      case RecurrentFrequency.quarterly:
        return 'Día ${expense.day} cada trimestre';
      case RecurrentFrequency.semiAnnually:
        return 'Día ${expense.day} cada 6 meses';
      case RecurrentFrequency.annually:
        return 'Día ${expense.day} cada año';
    }
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
