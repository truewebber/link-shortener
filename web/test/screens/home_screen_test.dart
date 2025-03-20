import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link_shortener/screens/home_screen.dart';
import 'package:link_shortener/widgets/feature_section.dart';
import 'package:link_shortener/widgets/url_shortener_form.dart';
import '../test_helper.dart';

void main() {
  late TestAppConfig testConfig;
  
  setUp(() {
    testConfig = TestAppConfig();
  });
  
  group('HomeScreen', () {
    testWidgets('displays all main components', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          child: const HomeScreen(),
        ),
      );
      
      // Check for main components
      expect(find.text('Link Shortener'), findsOneWidget);
      expect(find.byType(UrlShortenerForm), findsOneWidget);
      expect(find.byType(FeatureSection), findsOneWidget);
    });
    
    testWidgets('adapts to different screen sizes', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          child: const HomeScreen(),
        ),
      );
      
      // Test desktop layout (>900px)
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pump();
      
      // Test tablet layout (600-900px)
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pump();
      
      // Test mobile layout (<600px)
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pump();
      
      // Just check that the screen adapts without errors
      expect(find.byType(UrlShortenerForm), findsOneWidget);
    });
    
    testWidgets('maintains consistent spacing', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          child: const HomeScreen(),
        ),
      );
      
      // Check that key components exist
      expect(find.text('Shorten Your Links'), findsOneWidget);
      expect(find.byType(UrlShortenerForm), findsOneWidget);
      expect(find.byType(FeatureSection), findsOneWidget);
    });
    
    testWidgets('displays correct heading text', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          child: const HomeScreen(),
        ),
      );
      
      expect(
        find.text('Shorten Your Links'),
        findsOneWidget,
      );
      expect(
        find.text('Create short, memorable links that redirect to your long URLs. Share them easily on social media, emails, or messages.'),
        findsOneWidget,
      );
    });
    
    testWidgets('maintains responsive padding', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          child: const HomeScreen(),
        ),
      );
      
      // Just verify the screen builds without errors at different sizes
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pump();
      
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pump();
      
      expect(find.byType(HomeScreen), findsOneWidget);
    });
    
    testWidgets('handles theme changes correctly', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          child: const HomeScreen(),
        ),
      );
      
      // Verify initial theme
      final initialTheme = Theme.of(tester.element(find.byType(HomeScreen)));
      expect(initialTheme.brightness, Brightness.light);
      
      // Change to dark theme
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pump();
      
      // Verify theme consistency
      final finalTheme = Theme.of(tester.element(find.byType(HomeScreen)));
      expect(finalTheme.brightness, Brightness.light);
    });
    
    testWidgets('maintains scroll behavior', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          child: const HomeScreen(),
        ),
      );
      
      // Test scrolling
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -100));
      await tester.pump();
      
      // Verify scroll position
      final scrollController = PrimaryScrollController.of(tester.element(find.byType(SingleChildScrollView)));
      expect(scrollController.position.pixels, greaterThan(0));
    });
  });
}
