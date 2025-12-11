import 'package:flutter/material.dart';
class AppTheme {
  // Colors for light and dark modes
  static const Color primaryColor = Color(0xFF0A2472); // Navy Blue
  static const Color primaryDark = Color(0xFF071952);
  static const Color secondaryColor = Color(0xFF16BAC5); // Teal accent
  static const Color backgroundColor = Color(0xFFF8FAFF); // Light background
  static const Color surfaceColor = Colors.white;
  static const Color onPrimary = Colors.white;
  static const Color onBackground = Color(0xFF1A1A2E);
  static const Color onSurface = Color(0xFF2D3748);
  static const Color errorColor = Color(0xFFDC2626);
  static const Color successColor = Color(0xFF059669);
  static const Color warningColor = Color(0xFFD97706);
  static const Color infoColor = Color(0xFF2563EB);
  
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      onPrimary: onPrimary,
      secondary: secondaryColor,
      onSecondary: onPrimary,
      error: errorColor,
      onError: onPrimary,
      surface: surfaceColor,
      onSurface: onSurface,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: onPrimary,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: onPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: onPrimary,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: primaryColor.withAlpha(20),
      labelStyle: TextStyle(fontWeight: FontWeight.w500, color: onPrimary),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: onPrimary,
    ),
    listTileTheme: ListTileThemeData(
      tileColor: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF5D9CEC),
      secondary: Color(0xFF4ECDC4),
      surface: Color(0xFF16213E),
    ),
    scaffoldBackgroundColor: Color(0xFF1A1A2E),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF0F3460),
      elevation: 0,
      titleTextStyle: TextStyle(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: Color(0xFF16213E),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF0F3460),
      selectedItemColor: Color(0xFF5D9CEC),
      unselectedItemColor: Colors.grey,
    ),
  );
}
