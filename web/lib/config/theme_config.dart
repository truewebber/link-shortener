import 'package:flutter/material.dart';

class ThemeConfig {
  ThemeConfig._();

  static const Color primaryColor = Color(0xFF2196F3);
  
  static const Color secondaryColor = Color(0xFF03DAC6);
  
  static ThemeData get lightTheme => _createThemeData(brightness: Brightness.light);

  static ThemeData get darkTheme => _createThemeData(brightness: Brightness.dark);

  static ThemeData _createThemeData({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;
    final Color errorColor;
    if (isDark) {
      errorColor = const Color(0xFFCF6679);
    } else {
      errorColor = const Color(0xFFB00020);
    }

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: secondaryColor,
      onSecondary: Colors.black,
      error: errorColor,
      onError: Colors.white,
      surface: backgroundColor,
      onSurface: isDark ? Colors.white : Colors.black,
    );
    
    final textTheme = TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: isDark ? Colors.white : Colors.black,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: isDark ? Colors.white : Colors.black,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: isDark ? Colors.white70 : Colors.black54,
      ),
    );
    
    final inputDecorationTheme = InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: isDark ? Colors.white30 : Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: errorColor,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: errorColor,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
    );
    
    final elevatedButtonTheme = ElevatedButtonThemeData(
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
    
    final cardTheme = CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
    
    const pageTransitionsTheme = PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      },
    );
    
    return ThemeData(
      brightness: brightness,
      primaryColor: primaryColor,
      colorScheme: colorScheme,
      textTheme: textTheme,
      inputDecorationTheme: inputDecorationTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      cardTheme: cardTheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      pageTransitionsTheme: pageTransitionsTheme,
    );
  }
}
