import 'dart:math';
import 'package:flutter/material.dart';

class Responsive {
  static late double screenWidth;
  static late double screenHeight;
  static late double _scale;

  // Ajustamos la base a un tamaño ligeramente menor (390x844 - iPhone 13 aprox)
  // Esto hará que en el S23 (412x915) el factor de escala sea mayor (> 1.0)
  // logrando que los elementos se vean un poco más grandes.
  static const double _refWidth = 390;
  static const double _refHeight = 844;

  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;
    _scale = min(screenWidth / _refWidth, screenHeight / _refHeight);
  }
}

extension ResponsiveSize on num {
  /// Proporcional al ancho de pantalla (Base optimizada: 390)
  double get w => this * (Responsive.screenWidth / Responsive._refWidth);

  /// Proporcional al alto de pantalla (Base optimizada: 844)
  double get h => this * (Responsive.screenHeight / Responsive._refHeight);

  /// Escalado de fuentes con mayor presencia en pantallas grandes
  /// Suelo de seguridad del 90% para evitar letras demasiado pequeñas en iPhone 7
  double get sp => max(this * Responsive._scale, this * 0.90);
  
  /// Porcentaje del ancho de pantalla
  double get wp => Responsive.screenWidth * (this / 100);
  
  /// Porcentaje del alto de pantalla
  double get hp => Responsive.screenHeight * (this / 100);
}
