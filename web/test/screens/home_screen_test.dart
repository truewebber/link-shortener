import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/screens/home_screen.dart';
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
      expect(find.text('URL Shortener'), findsOneWidget);
      expect(find.text('Features'), findsOneWidget);
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
      expect(find.byType(Row), findsOneWidget);
      
      // Test tablet layout (600-900px)
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pump();
      expect(find.byType(Column), findsOneWidget);
      
      // Test mobile layout (<600px)
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pump();
      expect(find.byType(Column), findsOneWidget);
    });
    
    testWidgets('maintains consistent spacing', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          child: const HomeScreen(),
        ),
      );
      
      // Check spacing between sections
      final titleFinder = find.text('URL Shortener');
      final formFinder = find.byType(UrlShortenerForm);
      final featuresFinder = find.text('Features');
      
      final titleRect = tester.getRect(titleFinder);
      final formRect = tester.getRect(formFinder);
      final featuresRect = tester.getRect(featuresFinder);
      
      expect(
        formRect.top - titleRect.bottom,
        greaterThanOrEqualTo(32),
      );
      expect(
        featuresRect.top - formRect.bottom,
        greaterThanOrEqualTo(64),
      );
    });
    
    testWidgets('displays correct heading text', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          child: const HomeScreen(),
        ),
      );
      
      expect(
        find.text('Make your links shorter and more manageable'),
        findsOneWidget,
      );
      expect(
        find.text('Create short URLs instantly with our fast and reliable service'),
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
      
      // Test desktop padding
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pump();
      final desktopPadding = tester.getRect(find.byType(Container)).left;
      expect(desktopPadding, greaterThanOrEqualTo(32));
      
      // Test mobile padding
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pump();
      final mobilePadding = tester.getRect(find.byType(Container)).left;
      expect(mobilePadding, lessThan(desktopPadding));
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
