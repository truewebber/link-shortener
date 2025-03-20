import 'package:flutter/material.dart';

/// Configuration for app themes
///
/// Provides factory methods for creating light and dark themes
/// with consistent styling across the application.
class ThemeConfig {
  /// Private constructor to prevent direct instantiation
  ThemeConfig._();

  /// Primary brand color used throughout the app
  static const Color primaryColor = Color(0xFF2196F3);
  
  /// Secondary/accent color used throughout the app
  static const Color secondaryColor = Color(0xFF03DAC6);
  
  /// Light theme for the application
  ///
  /// Provides a consistent light theme with appropriate colors,
  /// text styles, and component themes.
  static ThemeData get lightTheme => _createThemeData(brightness: Brightness.light);

  /// Dark theme for the application
  ///
  /// Provides a consistent dark theme with appropriate colors,
  /// text styles, and component themes.
  static ThemeData get darkTheme => _createThemeData(brightness: Brightness.dark);

  /// Creates a theme data with specified brightness
  ///
  /// This internal method handles the creation of theme data
  /// with consistent styles across light and dark themes.
  static ThemeData _createThemeData({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    
    // Create different colors for dark and light themes
    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;
    final Color errorColor;
    if (isDark) {
      errorColor = const Color(0xFFCF6679);
    } else {
      errorColor = const Color(0xFFB00020);
    }
    
    // Create color scheme
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
    
    // Create text theme with consistent sizes across brightness modes
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
    
    // Create consistent input decoration
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
    
    // Create consistent button style
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
    
    // Create consistent card theme
    final cardTheme = CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
    
    // Create page transitions theme
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