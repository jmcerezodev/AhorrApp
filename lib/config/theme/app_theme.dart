import 'package:flutter/material.dart';

class AppTheme {
  ThemeData getTheme({bool isDarkMode = false}) {
    const primaryColor = Colors.orange;
    
    final scaffoldBg = isDarkMode ? const Color(0xFF0F1112) : const Color(0xFFFFFBF5);
    final surfaceColor = isDarkMode ? const Color(0xFF1A1C1E) : Colors.white;

    // Definimos el ColorScheme manualmente para evitar que Material 3 genere "morados"
    final colorScheme = isDarkMode 
      ? const ColorScheme.dark(
          primary: primaryColor,
          onPrimary: Colors.white,
          secondary: primaryColor,
          onSecondary: Colors.white,
          surface: Color(0xFF1A1C1E),
          onSurface: Colors.white,
          error: Colors.redAccent,
        )
      : ColorScheme.light(
          primary: primaryColor,
          onPrimary: Colors.white,
          secondary: primaryColor,
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.blueGrey.shade900,
          outline: Colors.orange.shade100,
          error: Colors.red.shade800,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: scaffoldBg,
      primaryColor: primaryColor,
      colorScheme: colorScheme,

      // ESTO ES LO QUE CONTROLA LA "GOTA" Y EL CURSOR GLOBALMENTE
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: primaryColor,
        selectionColor: Color(0x4DFF9800), // Naranja con 30% de opacidad
        selectionHandleColor: primaryColor,
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
        iconTheme: const IconThemeData(color: primaryColor),
      ),

      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: isDarkMode ? 0 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isDarkMode ? Colors.white10 : Colors.orange.shade50),
        ),
      ),

      listTileTheme: const ListTileThemeData(iconColor: primaryColor),
    );
  }
}
