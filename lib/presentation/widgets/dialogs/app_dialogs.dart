import 'package:flutter/material.dart';

/// Clase de utilidad para invocar diálogos siguiendo el estándar visual de AhorrApp.
class AppDialogs {
  
  /// Muestra un diálogo. El widget [builder] debe ser el encargado de 
  /// usar CustomDialogWrapper como su raíz para mantener el ADN visual.
  static Future<T?> showCustomDialog<T>({
    required BuildContext context,
    required Widget builder,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => builder,
    );
  }

  /// Cabecera centrada con el icono en un círculo (ADN de diálogos de estado)
  static Widget dialogHeader({
    Key? key,
    IconData? icon,
    Widget? customIcon,
    required Color color,
    required String title,
    bool circularBackground = true,
    double iconSize = 32,
    required ColorScheme colorScheme,
    Color? titleColor,
    double fontSize = 14,
  }) {
    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (circularBackground)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: customIcon ?? Icon(icon, color: color, size: iconSize),
          )
        else
          customIcon ?? Icon(icon, color: color, size: iconSize),
        
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: titleColor ?? colorScheme.onSurface.withValues(alpha: 0.7),
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  /// Cabecera en fila (ADN de diálogos de edición/inputs)
  static Widget dialogRowHeader({
    Key? key,
    required IconData icon,
    required String title,
    required Color color,
    required ColorScheme colorScheme,
  }) {
    return Row(
      key: key,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  static Widget dialogMessage(String message, ColorScheme colorScheme, {Color? customColor}) {
    return Text(
      message,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13,
        color: customColor ?? colorScheme.onSurface.withValues(alpha: 0.5),
        height: 1.5,
      ),
    );
  }

  static Widget dialogPrimaryButton({
    required String text,
    VoidCallback? onPressed,
    required Color color,
    bool isLoading = false,
  }) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        disabledBackgroundColor: color.withValues(alpha: 0.3),
      ),
      child: Center(
        child: isLoading
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
      ),
    );
  }
}
