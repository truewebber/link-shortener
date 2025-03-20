import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/config/theme_config.dart';

void main() {
  group('ThemeConfig', () {
    test('creates light theme correctly', () {
      final theme = ThemeConfig.lightTheme;
      
      expect(theme.brightness, Brightness.light);
      expect(theme.primaryColor, const Color(0xFF2196F3));
      expect(theme.colorScheme.primary, const Color(0xFF2196F3));
      expect(theme.colorScheme.secondary, const Color(0xFF03DAC6));
      expect(theme.colorScheme.error, const Color(0xFFB00020));
      expect(theme.colorScheme.background, Colors.white);
      expect(theme.colorScheme.surface, Colors.white);
    });
    
    test('creates dark theme correctly', () {
      final theme = ThemeConfig.darkTheme;
      
      expect(theme.brightness, Brightness.dark);
      expect(theme.primaryColor, const Color(0xFF2196F3));
      expect(theme.colorScheme.primary, const Color(0xFF2196F3));
      expect(theme.colorScheme.secondary, const Color(0xFF03DAC6));
      expect(theme.colorScheme.error, const Color(0xFFCF6679));
      expect(theme.colorScheme.background, const Color(0xFF121212));
      expect(theme.colorScheme.surface, const Color(0xFF121212));
    });
    
    test('applies consistent text styles', () {
      final lightTheme = ThemeConfig.lightTheme;
      final darkTheme = ThemeConfig.darkTheme;
      
      // Test heading styles
      expect(
        lightTheme.textTheme.headlineLarge?.fontSize,
        darkTheme.textTheme.headlineLarge?.fontSize,
      );
      expect(
        lightTheme.textTheme.headlineMedium?.fontSize,
        darkTheme.textTheme.headlineMedium?.fontSize,
      );
      expect(
        lightTheme.textTheme.headlineSmall?.fontSize,
        darkTheme.textTheme.headlineSmall?.fontSize,
      );
      
      // Test body styles
      expect(
        lightTheme.textTheme.bodyLarge?.fontSize,
        darkTheme.textTheme.bodyLarge?.fontSize,
      );
      expect(
        lightTheme.textTheme.bodyMedium?.fontSize,
        darkTheme.textTheme.bodyMedium?.fontSize,
      );
      expect(
        lightTheme.textTheme.bodySmall?.fontSize,
        darkTheme.textTheme.bodySmall?.fontSize,
      );
    });
    
    test('applies consistent input decoration', () {
      final lightTheme = ThemeConfig.lightTheme;
      final darkTheme = ThemeConfig.darkTheme;
      
      final lightInput = lightTheme.inputDecorationTheme;
      final darkInput = darkTheme.inputDecorationTheme;
      
      expect(lightInput.border, darkInput.border);
      expect(lightInput.enabledBorder, darkInput.enabledBorder);
      expect(lightInput.focusedBorder, darkInput.focusedBorder);
      expect(lightInput.errorBorder, darkInput.errorBorder);
      expect(lightInput.focusedErrorBorder, darkInput.focusedErrorBorder);
    });
    
    test('applies consistent button styles', () {
      final lightTheme = ThemeConfig.lightTheme;
      final darkTheme = ThemeConfig.darkTheme;
      
      final lightButton = lightTheme.elevatedButtonTheme;
      final darkButton = darkTheme.elevatedButtonTheme;
      
      expect(
        lightButton.style?.padding,
        darkButton.style?.padding,
      );
      expect(
        lightButton.style?.shape,
        darkButton.style?.shape,
      );
    });
    
    test('applies consistent card styles', () {
      final lightTheme = ThemeConfig.lightTheme;
      final darkTheme = ThemeConfig.darkTheme;
      
      final lightCard = lightTheme.cardTheme;
      final darkCard = darkTheme.cardTheme;
      
      expect(lightCard.elevation, darkCard.elevation);
      expect(lightCard.shape, darkCard.shape);
    });
    
    test('applies consistent spacing', () {
      final lightTheme = ThemeConfig.lightTheme;
      final darkTheme = ThemeConfig.darkTheme;
      
      expect(
        lightTheme.visualDensity,
        darkTheme.visualDensity,
      );
    });
    
    test('applies consistent animations', () {
      final lightTheme = ThemeConfig.lightTheme;
      final darkTheme = ThemeConfig.darkTheme;
      
      expect(
        lightTheme.pageTransitionsTheme,
        darkTheme.pageTransitionsTheme,
      );
    });
  });
}
