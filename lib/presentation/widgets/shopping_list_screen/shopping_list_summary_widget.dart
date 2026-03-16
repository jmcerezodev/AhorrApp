import 'package:ahorrapp/core/config/responsive_utils.dart';
import 'package:ahorrapp/core/numbers_format/humanize_numbers.dart';
import 'package:ahorrapp/presentation/bloc/shopping_cubit/shopping_list_cubit.dart';
import 'package:ahorrapp/presentation/widgets/dialogs/shopping_list_dialogs/add_edit_shopping_item_dialog.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShoppingSummaryWidget extends StatelessWidget {
  const ShoppingSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final humanizeNumbers = HumanizeNumbers();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<ShoppingListCubit, ShoppingState>(
      builder: (context, state) {
        return FadeInDown(
          duration: const Duration(milliseconds: 400),
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
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'TOTAL EN LA CESTA',
                              style: TextStyle(
                                color: Colors.orange.shade400,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              // REGLA DE ORO: Formato entero
                              '${humanizeNumbers.number(state.totalBoughtPrice.toInt().toDouble())}€',
                              style: TextStyle(
                                color: isDark ? Colors.white : colorScheme.onSurface,
                                fontSize: 30.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 12.h), 
                          
                          _BasketChip(
                            totalBought: state.totalBought,
                            totalItems: state.items.length,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 15.w),

                    const _AddProductBubble(),
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

class _AddProductBubble extends StatelessWidget {
  const _AddProductBubble();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AddEditShoppingItemDialog(),
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
              Icons.add_shopping_cart_rounded,
              color: Colors.orange,
              size: 32.w,
            ),
            SizedBox(height: 4.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'AÑADIR',
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

class _BasketChip extends StatelessWidget {
  final int totalBought;
  final int totalItems;
  final bool isDark;

  const _BasketChip({
    required this.totalBought,
    required this.totalItems,
    required this.isDark,
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
          Icon(Icons.shopping_basket_rounded, color: color.withValues(alpha: 0.8), size: 12.w),
          SizedBox(width: 6.w),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'EN LA CESTA',
              style: TextStyle(
                color: isDark ? Colors.white70 : colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 8.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            '$totalBought/$totalItems',
            style: TextStyle(
              color: isDark ? Colors.white : colorScheme.onSurface,
              fontSize: 10.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
