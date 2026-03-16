import 'package:flutter/material.dart';
import 'responsive_utils.dart';

class AppInputStyles {
  static InputDecoration decoration({
    required String labelText,
    required String hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
    String? errorText,
  }) {
    final bool isSmall = Responsive.isSmallScreen;
    
    // La "Fórmula del Éxito" validada
    final TextStyle standardStyle = TextStyle(
      fontSize: isSmall ? 11 : 14,
      fontWeight: FontWeight.w400,
      color: Colors.grey.shade600,
    );

    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.blueGrey.shade400) : null,
      suffixIcon: suffixIcon,
      errorText: errorText,
      hintStyle: standardStyle,
      labelStyle: standardStyle,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Colors.orange, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.red.shade800),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.red.shade800, width: 2),
      ),
    );
  }
}
