import 'package:ahorrapp/core/config/responsive_utils.dart';
import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/domain/entities/shopping_list_item.dart';
import 'package:ahorrapp/domain/entities/shopping_template.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_list_cubit.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_templates_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/shopping_list_dialogs/delete_favorite_dialog.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/shopping_list_dialogs/quick_price_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShoppingItemCard extends StatelessWidget {
  final ShoppingListItem item;
  final HumanizeNumbers humanizeNumbers;
  final ColorScheme colorScheme;
  final bool isDark;

  const ShoppingItemCard({
    super.key,
    required this.item,
    required this.humanizeNumbers,
    required this.colorScheme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width <= 375;

    return BlocBuilder<ShoppingTemplatesCubit, ShoppingTemplatesState>(
      builder: (context, templatesState) {
        final bool isAlreadyFavorite = templatesState.isFavorite(item.name);
        final String? favoriteId = templatesState.getFavoriteId(item.name);

        return GestureDetector(
          onTap: () => context.read<ShoppingListCubit>().toggleItem(item),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: BoxConstraints(minHeight: 75.h),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(18.w),
              border: Border.all(
                color: item.isBought 
                  ? Colors.green.withValues(alpha: 0.3)
                  : Colors.orange.withValues(alpha: 0.1),
                width: 1.5.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.015),
                  blurRadius: 10.w,
                  offset: Offset(0, 4.h),
                )
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 40.w,
                  child: Row(
                    children: [
                      // 1. ESTADO (CHECK)
                      _buildStatusIcon(),
                      
                      SizedBox(width: 12.w),

                      // 2. INFO DEL PRODUCTO
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14.sp,
                                color: item.isBought ? colorScheme.onSurface.withValues(alpha: 0.3) : colorScheme.onSurface,
                                decoration: item.isBought ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              item.category.toUpperCase(),
                              style: TextStyle(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w900,
                                color: Colors.orange.withValues(alpha: 0.7),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: 8.w),

                      // 3. ZONA DE ACCIÓN PROTEGIDA
                      GestureDetector(
                        onTap: () {}, 
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: item.amount > 0 
                            ? [
                                _buildPriceSectionWithQuantity(context),
                                SizedBox(width: 12.w),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildQuantityBadge(),
                                    _buildFavoriteIcon(context, isAlreadyFavorite, favoriteId),
                                  ],
                                ),
                                SizedBox(width: 10.w),
                                if (!item.isBought)
                                  _buildVerticalStepperMinimal(context)
                                else
                                  SizedBox(width: 24.w),
                              ]
                            : [
                                _buildFavoriteIcon(context, isAlreadyFavorite, favoriteId),
                                SizedBox(width: 10.w),
                                _buildPriceSectionWithQuantity(context),
                              ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIcon() {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: (item.isBought ? Colors.green : Colors.orange).withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(
        item.isBought ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
        color: item.isBought ? Colors.green : Colors.orange.withValues(alpha: 0.4),
        size: 18.w,
      ),
    );
  }

  Widget _buildVerticalStepperMinimal(BuildContext context) {
    return Container(
      width: 24.w,
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6.w),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepperButtonMinimal(
            icon: Icons.add_rounded,
            onTap: () => context.read<ShoppingListCubit>().updateItem(item.copyWith(quantity: item.quantity + 1)),
          ),
          _stepperButtonMinimal(
            icon: Icons.remove_rounded,
            onTap: item.quantity > 1 
              ? () => context.read<ShoppingListCubit>().updateItem(item.copyWith(quantity: item.quantity - 1))
              : null,
          ),
        ],
      ),
    );
  }

  Widget _stepperButtonMinimal({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 24.w,
        padding: EdgeInsets.symmetric(vertical: 6.h), 
        color: Colors.transparent, 
        child: Icon(
          icon, 
          size: 16.w, 
          color: onTap != null ? Colors.orange : Colors.grey.withValues(alpha: 0.2)
        ),
      ),
    );
  }

  Widget _buildQuantityBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: item.isBought ? 0.4 : 1.0),
        borderRadius: BorderRadius.circular(6.w),
      ),
      child: Text(
        'x${item.quantity}',
        style: TextStyle(
          color: Colors.white,
          fontSize: 8.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildPriceSectionWithQuantity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (item.amount > 0) ...[
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${humanizeNumbers.number((item.amount * item.quantity).toInt().toDouble())}€',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14.sp,
                color: item.isBought ? colorScheme.onSurface.withValues(alpha: 0.2) : colorScheme.onSurface,
              ),
            ),
          ),
          if (item.quantity > 1)
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${humanizeNumbers.number(item.amount.toInt().toDouble())}€/ud',
                style: TextStyle(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.orange.withValues(alpha: item.isBought ? 0.4 : 0.8),
                ),
              ),
            ),
        ] else
          GestureDetector(
            onTap: () => _showQuickPrice(context),
            behavior: HitTestBehavior.opaque,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 4.h),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.w),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 14.w, color: Colors.orange),
                  SizedBox(width: 4.w),
                  Text(
                    'PRECIO',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showQuickPrice(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => QuickPriceDialog(item: item),
    );
  }

  Widget _buildFavoriteIcon(BuildContext context, bool isAlreadyFavorite, String? favoriteId) {
    return GestureDetector(
      onTap: () {
        if (isAlreadyFavorite && favoriteId != null) {
          showDialog(
            context: context,
            builder: (_) => BlocProvider.value(
              value: context.read<ShoppingTemplatesCubit>(),
              child: DeleteFavoriteDialog(templateId: favoriteId, productName: item.name),
            ),
          );
        } else {
          context.read<ShoppingTemplatesCubit>().saveTemplate(
            item.name, 
            [ShoppingTemplateItem(name: item.name, amount: item.amount, category: item.category)]
          );
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.all(8.0.w), 
        color: Colors.transparent,
        child: Icon(
          isAlreadyFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 22.w,
          color: Colors.orange.withValues(alpha: isAlreadyFavorite ? 1.0 : 0.4),
        ),
      ),
    );
  }
}
