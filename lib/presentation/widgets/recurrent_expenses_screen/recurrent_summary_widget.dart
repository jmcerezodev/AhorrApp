import 'package:ahorrapp/core/config/responsive_utils.dart';
import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/recurrent_expenses_dialogs/add_edit_recurrent_expense_dialog.dart';
import 'package:ahorrapp/presentation/widgets/widgets.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecurrentSummaryWidget extends StatelessWidget {
  final bool isIncomeTab;

  const RecurrentSummaryWidget({
    super.key,
    required this.isIncomeTab,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final humanizeNumbers = HumanizeNumbers();
    final colorScheme = Theme.of(context).colorScheme;
    final isPrivacyActive = context.watch<ThemeCubit>().state.isPrivacyModeActive;

    return BlocBuilder<RecurrentExpensesCubit, RecurrentExpensesState>(
      builder: (context, state) {
        final double totalToShow = state.showProrated 
            ? (isIncomeTab ? state.totalIncomeProrated : state.totalExpenseProrated)
            : (isIncomeTab ? state.totalIncomeStrict : state.totalExpenseStrict);

        return FadeInDown(
          duration: const Duration(milliseconds: 1000),
          from: 50.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                gradient: isDark 
                  ? const LinearGradient(
                      colors: [Color(0xFF2C2C2C), Color(0xFF1E1E1E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
                borderRadius: BorderRadius.circular(25.w),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: isDark ? 0.1 : 0.3), 
                  width: 1.5.w
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15.w,
                    offset: Offset(0, 8.h),
                  )
                ],
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  isIncomeTab ? 'TOTAL INGRESOS' : 'TOTAL GASTOS',
                                  softWrap: false,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.orange.shade400,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              SizedBox(width: 4.w),
                              GestureDetector(
                                onTap: () => context.read<ThemeCubit>().togglePrivacyMode(),
                                child: Icon(
                                  isPrivacyActive ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  size: 14.w,
                                  color: Colors.orange.shade400.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: PrivacyAmountText(
                              // REGLA DE ORO: Formato entero
                              amount: '${humanizeNumbers.number(totalToShow.toInt().toDouble(), isPrivacyModeActive: isPrivacyActive)}€',
                              isPrivacyActive: isPrivacyActive,
                              style: TextStyle(
                                color: isDark ? Colors.white : colorScheme.onSurface,
                                fontSize: 30.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 12.h),
                          
                          GestureDetector(
                            onTap: () => context.read<RecurrentExpensesCubit>().toggleProratedView(),
                            behavior: HitTestBehavior.opaque,
                            child: _ModeChip(
                              showProrated: state.showProrated,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 15.w),

                    _AddRecurrentBubble(isIncome: isIncomeTab),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AddRecurrentBubble extends StatelessWidget {
  final bool isIncome;
  const _AddRecurrentBubble({required this.isIncome});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AddEditRecurrentExpenseDialog(isIncome: isIncome),
        );
      },
      child: Container(
        width: 110.w,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20.w),
          border: Border.all(
            color: Colors.orange.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_box_rounded,
              color: Colors.orange,
              size: 32.w,
            ),
            SizedBox(height: 4.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                isIncome ? 'NUEVO INGRESO' : 'NUEVO GASTO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.orange,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final bool showProrated;
  final bool isDark;

  const _ModeChip({
    required this.showProrated, 
    required this.isDark
  });

  @override
  Widget build(BuildContext context) {
    final color = Colors.orange.shade400;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.w),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sync_rounded, color: color.withValues(alpha: 0.8), size: 12.w),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              showProrated ? 'TOTAL PRORRATEADO' : 'TOTAL MENSUAL',
              softWrap: false,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white70 : colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 8.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
