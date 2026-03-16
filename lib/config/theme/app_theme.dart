import 'package:flutter/material.dart';
import 'package:ahorrapp/core/config/responsive_utils.dart';

class AppTheme {
  ThemeData getTheme({bool isDarkMode = false}) {
    // ADN AhorrApp: Naranja exacto #FFA500
    const primaryOrange = Color(0xFFFFA500);
    const backgroundCream = Color(0xFFFFFBF5);
    const darkBg = Color(0xFF0F1112);
    const darkSurface = Color(0xFF1A1C1E);
    
    final scaffoldBg = isDarkMode ? darkBg : backgroundCream;
    final surfaceColor = isDarkMode ? darkSurface : Colors.white;

    final colorScheme = isDarkMode 
      ? const ColorScheme.dark(
          primary: primaryOrange,
          onPrimary: Colors.white,
          secondary: primaryOrange,
          onSecondary: Colors.white,
          surface: darkSurface,
          onSurface: Colors.white,
          error: Colors.redAccent,
        )
      : ColorScheme.light(
          primary: primaryOrange,
          onPrimary: Colors.white,
          secondary: primaryOrange,
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: const Color(0xFF263238), // blueGrey.shade900
          outline: const Color(0xFFFFE0B2), // Borde sutil #FFE0B2
          error: const Color(0xFFC62828), // red.shade800
        );

    // Ajuste dinámico de fuente: 10 (hardcoded para test) en pantallas pequeñas, 14.sp para el resto
    final double dynamicFontSize = Responsive.isSmallScreen ? 10 : 14.sp;

    return ThemeData(
      useMaterial3: true,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: scaffoldBg,
      primaryColor: primaryOrange,
      colorScheme: colorScheme,

      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: primaryOrange,
        selectionColor: Color(0x4DFFA500), // Naranja #FFA500 con 30% de opacidad
        selectionHandleColor: primaryOrange,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        elevation: 0.0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: primaryOrange),
      ),

      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: isDarkMode ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // ADN: 20px
          side: BorderSide(color: isDarkMode ? Colors.white10 : const Color(0xFFFFE0B2)),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // ADN: 15px
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryOrange,
          side: const BorderSide(color: primaryOrange),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // ADN: 15px
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryOrange,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: dynamicFontSize,
          fontWeight: FontWeight.normal,
        ),
        labelStyle: TextStyle(
          color: Colors.grey.shade600,
          fontSize: dynamicFontSize,
        ),
        floatingLabelStyle: TextStyle(
          color: primaryOrange,
          fontSize: dynamicFontSize,
          fontWeight: FontWeight.bold,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: isDarkMode ? Colors.white24 : const Color(0xFFFFE0B2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: isDarkMode ? Colors.white24 : const Color(0xFFFFE0B2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primaryOrange, width: 2),
        ),
        prefixIconColor: primaryOrange,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),

      listTileTheme: const ListTileThemeData(iconColor: primaryOrange),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
      ),
    );
  }
}
