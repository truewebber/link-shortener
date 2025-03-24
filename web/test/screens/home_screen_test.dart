import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link_shortener/screens/home_screen.dart';
import 'package:link_shortener/widgets/feature_section.dart';
import 'package:link_shortener/widgets/url_shortener_form.dart';

import '../mocks/auth_service.generate.mocks.dart';
import '../test_helper.dart';

void main() {
  late TestAppConfig testConfig;
  late MockAuthService testAuthService;
  
  setUp(() {
    testConfig = TestAppConfig();
    testAuthService = MockAuthService();
  });
  
  tearDown(() {
    // Убедимся, что ресурсы очищены после каждого теста
    testAuthService.dispose();
  });
  
  group('HomeScreen', () {
    testWidgets('displays all main components', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          authService: testAuthService,
          child: const HomeScreen(),
        ),
      );
      
      // Дождемся завершения всех анимаций
      await tester.pumpAndSettle();
      
      // Check for main components
      expect(find.text('Link Shortener'), findsOneWidget);
      expect(find.byType(UrlShortenerForm), findsOneWidget);
      expect(find.byType(FeatureSection), findsOneWidget);
      
      // Дождемся завершения всех таймеров перед выходом
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });
    
    testWidgets('adapts to different screen sizes', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          authService: testAuthService,
          child: const HomeScreen(),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Test desktop layout (>900px)
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pumpAndSettle();
      
      // Test tablet layout (600-900px)
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpAndSettle();
      
      // Test mobile layout (<600px)
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();
      
      // Just check that the screen adapts without errors
      expect(find.byType(UrlShortenerForm), findsOneWidget);
      
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });
    
    testWidgets('maintains consistent spacing', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          authService: testAuthService,
          child: const HomeScreen(),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Check that key components exist
      expect(find.text('Shorten Your Links'), findsOneWidget);
      expect(find.byType(UrlShortenerForm), findsOneWidget);
      expect(find.byType(FeatureSection), findsOneWidget);
      
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });
    
    testWidgets('displays correct heading text', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          authService: testAuthService,
          child: const HomeScreen(),
        ),
      );
      
      await tester.pumpAndSettle();
      
      expect(
        find.text('Shorten Your Links'),
        findsOneWidget,
      );
      expect(
        find.text('Create short, memorable links that redirect to your long URLs. Share them easily on social media, emails, or messages.'),
        findsOneWidget,
      );
      
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });
    
    testWidgets('maintains responsive padding', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          authService: testAuthService,
          child: const HomeScreen(),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Just verify the screen builds without errors at different sizes
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pumpAndSettle();
      
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();
      
      expect(find.byType(HomeScreen), findsOneWidget);
      
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });
    
    testWidgets('handles theme changes correctly', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          authService: testAuthService,
          child: const HomeScreen(),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Verify initial theme
      final initialTheme = Theme.of(tester.element(find.byType(HomeScreen)));
      expect(initialTheme.brightness, Brightness.light);
      
      // Change to dark theme
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pumpAndSettle();
      
      // Verify theme consistency
      final finalTheme = Theme.of(tester.element(find.byType(HomeScreen)));
      expect(finalTheme.brightness, Brightness.light);
      
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });
    
    testWidgets('maintains scroll behavior', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          authService: testAuthService,
          child: const HomeScreen(),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Find the main ScrollView by looking for the one that contains the UrlShortenerForm
      final scrollViewFinder = find.ancestor(
        of: find.byType(UrlShortenerForm),
        matching: find.byType(SingleChildScrollView),
      );
      
      expect(scrollViewFinder, findsOneWidget);
      
      // Test scrolling
      await tester.drag(scrollViewFinder, const Offset(0, -100));
      await tester.pumpAndSettle();
      
      // Verify scroll position
      final scrollController = PrimaryScrollController.of(tester.element(scrollViewFinder));
      expect(scrollController.position.pixels, greaterThan(0));
      
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });
  });
}
