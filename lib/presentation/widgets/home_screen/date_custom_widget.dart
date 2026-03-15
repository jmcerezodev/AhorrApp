import 'package:ahorrapp/core/config/responsive_utils.dart';
import 'package:ahorrapp/core/singletons/global_variables_singleton.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class DateCustomWidget extends StatelessWidget {
  const DateCustomWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final singleton = Singleton();
    final dateCubit = context.watch<DateCubit>();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => dateCubit.isOpen(!dateCubit.state.isOpen),
      child: Container(
        height: 55.h,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20.w),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 18.sp, color: colorScheme.primary),
              SizedBox(width: 10.w),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  context.select((DateCubit value) {
                    if (value.state.month == '') {
                      value.currentMonth();
                      value.currentYear();
                    }
                    singleton.currentDate['year'] = value.state.year.toString();
                    singleton.currentDate['month'] = value.state.month;
                    return '${value.state.month} ${value.state.year}';
                  }),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                dateCubit.state.isOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
