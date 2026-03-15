import 'package:ahorrapp/core/config/responsive_utils.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class CustomDialogWrapper extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final double horizontalInsetPadding;
  final bool animate;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? padding;
  final bool wrapInScrollView;

  const CustomDialogWrapper({
    super.key,
    required this.child,
    this.borderColor,
    this.horizontalInsetPadding = 20,
    this.animate = true,
    this.constraints,
    this.padding,
    this.wrapInScrollView = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final effectiveBorderColor = borderColor ?? 
        colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.4);

    Widget card = Container(
      constraints: constraints ?? BoxConstraints(
        maxHeight: 700.h, // Altura máxima responsiva para evitar overflows
      ),
      padding: padding ?? EdgeInsets.all(25.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(30.w),
        border: Border.all(
          color: effectiveBorderColor,
          width: 1.5.w,
        ),
      ),
      child: child,
    );

    if (animate) {
      card = FadeInUp(
        duration: const Duration(milliseconds: 300),
        child: card,
      );
    }

    Widget content = card;
    if (wrapInScrollView) {
      content = SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: card,
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      // Inset padding responsivo para que respire en iPhone 7
      insetPadding: EdgeInsets.symmetric(
        horizontal: horizontalInsetPadding.w,
        vertical: 24.h,
      ),
      child: content,
    );
  }
}
