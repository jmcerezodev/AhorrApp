import 'package:ahorrapp/core/config/responsive_utils.dart';
import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:flutter/material.dart';

class RecurrentFilterPanel extends StatelessWidget {
  final RecurrentExpensesCubit cubit;
  const RecurrentFilterPanel({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = cubit.state;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h, top: 2.h, left: 20.w, right: 20.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18.w),
        border: Border.all(color: colorScheme.primary.withValues(alpha: isDark ? 0.1 : 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _FilterChip(
                label: 'Automáticos',
                value: state.showAutomatic,
                activeColor: Colors.orange,
                onChanged: (val) => cubit.toggleAutomaticFilter(val),
              ),
              _FilterChip(
                label: 'Manuales',
                value: state.showManual,
                activeColor: Colors.orange,
                onChanged: (val) => cubit.toggleManualFilter(val),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
            child: Divider(height: 1.h, thickness: 0.5),
          ),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            alignment: WrapAlignment.center,
            children: [
              _CategoryFilterItem(id: 'general', icon: Icons.receipt_long_rounded, isSelected: state.selectedCategories.contains('general'), onTap: () => cubit.toggleCategoryFilter('general')),
              _CategoryFilterItem(id: 'hogar', icon: Icons.home_work_rounded, isSelected: state.selectedCategories.contains('hogar'), onTap: () => cubit.toggleCategoryFilter('hogar')),
              _CategoryFilterItem(id: 'suscripción', icon: Icons.subscriptions_rounded, isSelected: state.selectedCategories.contains('suscripción'), onTap: () => cubit.toggleCategoryFilter('suscripción')),
              _CategoryFilterItem(id: 'salud', icon: Icons.favorite_rounded, isSelected: state.selectedCategories.contains('salud'), onTap: () => cubit.toggleCategoryFilter('salud')),
              _CategoryFilterItem(id: 'transporte', icon: Icons.directions_car_rounded, isSelected: state.selectedCategories.contains('transporte'), onTap: () => cubit.toggleCategoryFilter('transporte')),
              _CategoryFilterItem(id: 'ocio', icon: Icons.sports_esports_rounded, isSelected: state.selectedCategories.contains('ocio'), onTap: () => cubit.toggleCategoryFilter('ocio')),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryFilterItem extends StatelessWidget {
  final String id;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryFilterItem({required this.id, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.orange.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? Colors.orange : Colors.orange.withValues(alpha: 0.2), width: 1.5.w),
        ),
        child: Icon(icon, size: 16.w, color: isSelected ? Colors.white : Colors.orange.withValues(alpha: 0.6)),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool value;
  final Color activeColor;
  final Function(bool) onChanged;

  const _FilterChip({required this.label, required this.value, required this.activeColor, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: (value ? activeColor : colorScheme.onSurface).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                value ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: value ? activeColor : colorScheme.onSurface.withValues(alpha: 0.3),
                size: 16.w,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w900,
                color: value ? activeColor : colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
