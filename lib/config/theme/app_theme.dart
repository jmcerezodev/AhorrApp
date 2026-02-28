import 'package:flutter/material.dart';

class AppTheme {
  ThemeData getTheme({bool isDarkMode = false}) {
    const primaryColor = Colors.orange;
    const secondaryColor = Colors.deepOrangeAccent;

    return ThemeData(
      useMaterial3: true,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      
      appBarTheme: AppBarTheme(
        backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
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

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),

      cardTheme: CardThemeData(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: isDarkMode ? 0 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: primaryColor,
      ),
    );
  }
}
