import 'package:ahorrapp/presentation/bloc/cubits.dart';
import 'package:animate_do/animate_do.dart';
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
      margin: const EdgeInsets.only(bottom: 8, top: 2, left: 20, right: 20),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            child: Divider(height: 1, thickness: 0.5),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.orange.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? Colors.orange : Colors.orange.withValues(alpha: 0.2), width: 1.5),
        ),
        child: Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.orange.withValues(alpha: 0.6)),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: value,
            onChanged: (val) => onChanged(val!),
            activeColor: activeColor,
            visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: value ? activeColor : colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
