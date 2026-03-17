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
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    // Altura útil: entre la barra de estado (top) y el teclado (bottom)
    final usableHeight = screenSize.height - mediaQuery.padding.top - keyboardHeight;

    final effectiveBorderColor = borderColor ??
        colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.4);

    Widget card = Container(
      constraints: constraints ??
          BoxConstraints(
            maxWidth: screenSize.width - (horizontalInsetPadding * 2).w,
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

    // Estructura con clamp:
    // SafeArea protege el notch/barra de estado en el techo.
    // SizedBox limita el área de scroll a exactamente
    //   screenHeight - padding.top - keyboardHeight
    // así el diálogo no puede subir más allá del techo ni
    // bajar por debajo del teclado. BouncingPhysics da el
    // rebote elástico de iOS en ambos extremos.
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: SafeArea(
        bottom: false, // el teclado ya actúa como límite inferior
        child: SizedBox(
          width: screenSize.width,
          height: usableHeight,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              // minHeight igual a la zona útil: la tarjeta queda
              // centrada cuando no hay scroll y los extremos del
              // BouncingScrollPhysics coinciden con los límites reales.
              constraints: BoxConstraints(minHeight: usableHeight),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalInsetPadding.w,
                    vertical: 16.h,
                  ),
                  child: card,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
