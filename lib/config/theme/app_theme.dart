import 'package:flutter/material.dart';

class AppTheme {
  ThemeData getTheme({bool isDarkMode = false}) {
    const primaryColor = Colors.orange;
    
    // Colores de fondo dinámicos
    final scaffoldBg = isDarkMode ? const Color(0xFF0F1112) : const Color(0xFFFFFBF5);
    final surfaceColor = isDarkMode ? const Color(0xFF1A1C1E) : Colors.white;

    return ThemeData(
      useMaterial3: true,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: scaffoldBg,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primary: primaryColor,
        surface: surfaceColor,
        onSurface: isDarkMode ? Colors.white : Colors.blueGrey.shade900,
        outline: isDarkMode ? Colors.orange.shade200.withValues(alpha: 0.2) : Colors.orange.shade100,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
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
          side: BorderSide(
            color: isDarkMode ? Colors.white10 : Colors.orange.shade50,
          ),
        ),
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: primaryColor,
      ),
    );
  }
}
