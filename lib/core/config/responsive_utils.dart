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
}

extension ResponsiveSize on num {
  /// Proporcional al ancho de pantalla
  double get w => this * (Responsive.screenWidth / Responsive._refWidth);

  /// Proporcional al alto de pantalla
  double get h => this * (Responsive.screenHeight / Responsive._refHeight);

  /// Escalado de fuentes refinado.
  /// Para pantallas pequeñas (como iPhone 7), permitimos bajar hasta un 85% del tamaño original
  /// para mejorar la legibilidad y evitar amontonamientos.
  double get sp => max(this * Responsive._scale, this * 0.85);
  
  /// Porcentaje del ancho de pantalla
  double get wp => Responsive.screenWidth * (this / 100);
  
  /// Porcentaje del alto de pantalla
  double get hp => Responsive.screenHeight * (this / 100);
}
