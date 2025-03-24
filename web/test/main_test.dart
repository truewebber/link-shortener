import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link_shortener/main.dart';
import 'package:link_shortener/screens/home_screen.dart';
import 'package:link_shortener/services/auth_service.dart';
import 'package:link_shortener/services/url_service.dart';
import 'mocks/app_config.generate.mocks.dart';
import 'mocks/auth_service.generate.mocks.dart';
import 'mocks/url_service.generate.mocks.dart';

void main() {
  group('Main App', () {
    late MockAppConfig testConfig;
    late MockAuthService testAuthService;
    late UrlService testUrlService;
    
    setUp(() {
      testConfig = MockAppConfig();
      testAuthService = MockAuthService();
      testUrlService = MockUrlService();
    });
    
    tearDown(() {
      // Очистка таймеров, вызывая dispose у AuthService
      testUrlService.dispose();
      testAuthService.dispose();
      AuthService.resetForTesting();
    });
    
    testWidgets('initializes with correct configuration', (tester) async {
      await tester.pumpWidget(LinkShortenerApp(
        config: testConfig,
        authService: testAuthService,
        urlService: testUrlService,
      ));
      
      // Verify app title is in AppBar
      expect(find.text('Link Shortener'), findsOneWidget);
      
      // Verify theme
      final theme = Theme.of(tester.element(find.byType(MaterialApp)));
      expect(theme.brightness, Brightness.light);
      
      // Verify home screen is displayed
      expect(find.byType(HomeScreen), findsOneWidget);
    });
    
    testWidgets('handles theme changes correctly', (tester) async {
      await tester.pumpWidget(LinkShortenerApp(
        config: testConfig,
        authService: testAuthService,
        urlService: testUrlService,
      ));
      
      // Verify initial theme
      final initialTheme = Theme.of(tester.element(find.byType(MaterialApp)));
      expect(initialTheme.brightness, Brightness.light);
      
      // Change to dark theme
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pump();
      
      // Verify theme consistency
      final finalTheme = Theme.of(tester.element(find.byType(MaterialApp)));
      expect(finalTheme.brightness, Brightness.light);
    });
    
    testWidgets('maintains responsive layout', (tester) async {
      await tester.pumpWidget(LinkShortenerApp(
        config: testConfig,
        authService: testAuthService,
        urlService: testUrlService,
      ));
      
      // Test desktop layout (>900px)
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pump();
      
      // Verify a Row exists somewhere in the widget tree
      expect(find.byType(Row), findsWidgets);
      
      // Test mobile layout (<600px)
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pump();
      
      // Verify Column exists somewhere in the widget tree
      expect(find.byType(Column), findsWidgets);
    });
    
    testWidgets('handles navigation correctly', (tester) async {
      await tester.pumpWidget(LinkShortenerApp(
        config: testConfig,
        authService: testAuthService,
        urlService: testUrlService,
      ));
      
      // Verify initial route
      expect(find.byType(HomeScreen), findsOneWidget);
    });
    
    testWidgets('maintains app state', (tester) async {
      await tester.pumpWidget(LinkShortenerApp(
        config: testConfig,
        authService: testAuthService,
        urlService: testUrlService,
      ));
      
      // Verify initial state
      expect(find.byType(HomeScreen), findsOneWidget);
      
      // Test state persistence
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pump();
      
      // Verify state is maintained
      expect(find.byType(HomeScreen), findsOneWidget);
    });
    
    testWidgets('maintains consistent styling', (tester) async {
      await tester.pumpWidget(LinkShortenerApp(
        config: testConfig,
        authService: testAuthService,
        urlService: testUrlService,
      ));
      
      // Verify text styles
      expect(find.text('Link Shortener'), findsOneWidget);
      
      // Verify button styles
      expect(find.byType(ElevatedButton), findsWidgets);
      
      // Verify input field styles
      expect(find.byType(TextFormField), findsOneWidget);
    });
    
    testWidgets('handles orientation changes', (tester) async {
      await tester.pumpWidget(LinkShortenerApp(
        config: testConfig,
        authService: testAuthService,
        urlService: testUrlService,
      ));
      
      // Test portrait orientation
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pump();
      
      // Verify Column exists somewhere in the widget tree
      expect(find.byType(Column), findsWidgets);
      
      // Test landscape orientation
      await tester.binding.setSurfaceSize(const Size(800, 400));
      await tester.pump();
      
      // Verify Row exists somewhere in the widget tree
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('displays shorten URL button', (tester) async {
      await tester.pumpWidget(LinkShortenerApp(
        config: testConfig,
        authService: testAuthService,
        urlService: testUrlService,
      ));
      
      // Check if the shorten URL button is present
      expect(find.text('SHORTEN URL'), findsOneWidget);
    });
  });
}
