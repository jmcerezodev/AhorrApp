import 'dart:math';
import 'package:flutter/material.dart';

class Responsive {
  static late double screenWidth;
  static late double screenHeight;
  static late double _scale;

  static const double _refWidth = 390;
  static const double _refHeight = 844;

  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    // Usamos el mínimo para asegurar que quepa en ambas dimensiones
    _scale = min(screenWidth / _refWidth, screenHeight / _refHeight);
  }

  /// Indica si la pantalla es pequeña (tipo iPhone 7/8/SE o menor)
  /// Aumentamos el umbral a 380 para asegurar que el iPhone 7 (375) siempre sea detectado.
  static bool get isSmallScreen => screenWidth <= 380;
}

extension ResponsiveSize on num {
  /// Proporcional al ancho de pantalla
  double get w => this * (Responsive.screenWidth / Responsive._refWidth);

  /// Proporcional al alto de pantalla
  double get h => this * (Responsive.screenHeight / Responsive._refHeight);

  /// Escalado de fuentes refinado.
  double get sp => max(this * Responsive._scale, this * 0.85);
  
  /// Porcentaje del ancho de pantalla
  double get wp => Responsive.screenWidth * (this / 100);
  
  /// Porcentaje del alto de pantalla
  double get hp => Responsive.screenHeight * (this / 100);
}
