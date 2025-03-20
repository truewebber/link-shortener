import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link_shortener/main.dart';
import 'package:link_shortener/screens/home_screen.dart';
import '../test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestAppConfig testConfig;

  setUp(() {
    testConfig = TestAppConfig();
  });

  group('URL Shortener End-to-End', () {
    testWidgets('loads app and renders base components', (tester) async {
      await tester.pumpWidget(
        LinkShortenerApp(config: testConfig),
      );

      // Verify initial state
      expect(find.text('Link Shortener'), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('SHORTEN URL'), findsOneWidget);
      
      // Verify anonymous user notice
      expect(
        find.text('Note: Links created by anonymous users expire after 3 months.'),
        findsOneWidget,
      );
    });
    
    testWidgets('handles theme changes correctly', (tester) async {
      await tester.pumpWidget(
        LinkShortenerApp(config: testConfig),
      );

      // Verify theme is initialized
      final theme = Theme.of(tester.element(find.byType(MaterialApp)));
      expect(theme.brightness, Brightness.light);
    });

    testWidgets('handles responsive layout changes', (tester) async {
      await tester.pumpWidget(
        LinkShortenerApp(config: testConfig),
      );

      // Test different layouts
      // Set desktop size
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pump();
      
      // Finding widgets in different sizes should still work
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('SHORTEN URL'), findsOneWidget);
    });

    testWidgets('shows features section', (tester) async {
      await tester.pumpWidget(
        LinkShortenerApp(config: testConfig),
      );

      // Verify features are displayed
      expect(find.text('Features'), findsOneWidget);
      expect(find.text('Fast & Reliable'), findsOneWidget);
      expect(find.text('Link Analytics'), findsOneWidget);
      expect(find.text('Custom Expiration'), findsOneWidget);
    });
  });
}