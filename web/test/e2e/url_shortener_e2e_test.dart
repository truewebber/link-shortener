import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestAppConfig testConfig;

  setUp(() {
    testConfig = TestAppConfig();
  });

  group('URL Shortener End-to-End', () {
    testWidgets('completes full user journey successfully', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          child: const MyApp(),
        ),
      );

      // Verify initial state
      expect(find.text('URL Shortener'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      // Enter URL
      const longUrl = 'https://example.com/very/long/url';
      await tester.enterText(find.byType(TextFormField), longUrl);

      // Submit form
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for API response
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verify success state
      expect(find.text('URL shortened successfully!'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);

      // Copy shortened URL
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // Verify copy success
      expect(find.text('Copied to clipboard!'), findsOneWidget);

      // Verify URL history
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('handles multiple URL shortening attempts', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          child: const MyApp(),
        ),
      );

      // First URL
      const url1 = 'https://example.com/url1';
      await tester.enterText(find.byType(TextFormField), url1);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Second URL
      const url2 = 'https://example.com/url2';
      await tester.enterText(find.byType(TextFormField), url2);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verify history
      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets('handles app state persistence', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          child: const MyApp(),
        ),
      );

      // Enter and shorten URL
      const longUrl = 'https://example.com/very/long/url';
      await tester.enterText(find.byType(TextFormField), longUrl);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Rebuild app
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          child: const MyApp(),
        ),
      );

      // Verify history persistence
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('handles theme changes', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          child: const MyApp(),
        ),
      );

      // Verify initial theme
      final initialTheme = Theme.of(tester.element(find.byType(MyApp)));
      expect(initialTheme.brightness, Brightness.light);

      // Change theme
      await tester.tap(find.byIcon(Icons.brightness_6));
      await tester.pumpAndSettle();

      // Verify theme change
      final finalTheme = Theme.of(tester.element(find.byType(MyApp)));
      expect(finalTheme.brightness, Brightness.dark);
    });

    testWidgets('handles responsive layout changes', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          child: const MyApp(),
        ),
      );

      // Test desktop layout
      await tester.binding.setSurfaceSize(const Size(1000, 800));
      await tester.pump();
      expect(find.byType(Row), findsOneWidget);

      // Test tablet layout
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pump();
      expect(find.byType(Column), findsOneWidget);

      // Test mobile layout
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pump();
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('handles orientation changes', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          child: const MyApp(),
        ),
      );

      // Test portrait orientation
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pump();
      expect(find.byType(Column), findsOneWidget);

      // Test landscape orientation
      await tester.binding.setSurfaceSize(const Size(800, 400));
      await tester.pump();
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('handles accessibility features', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          child: const MyApp(),
        ),
      );

      // Verify screen reader support
      expect(find.bySemanticsLabel('URL input field'), findsOneWidget);
      expect(find.bySemanticsLabel('Shorten URL button'), findsOneWidget);

      // Verify keyboard navigation
      await tester.enterText(find.byType(TextFormField), 'https://example.com');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify focus management
      expect(find.byType(Focus), findsOneWidget);
    });
  });
}