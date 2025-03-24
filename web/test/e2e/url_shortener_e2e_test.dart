import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link_shortener/main.dart';
import 'package:link_shortener/screens/home_screen.dart';
import 'package:link_shortener/services/auth_service.dart';
import 'package:link_shortener/services/url_service.dart';

import '../mocks/auth_service.generate.mocks.dart';
import '../mocks/url_service.generate.mocks.dart';
import '../test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestAppConfig testConfig;
  late MockAuthService testAuthService;
  late UrlService testUrlService;

  setUp(() {
    testConfig = TestAppConfig();
    testAuthService = MockAuthService();
    testUrlService = MockUrlService();
  });
  
  tearDown(() {
    // Ensure the AuthService is disposed to clean up timers
    testUrlService.dispose();
    testAuthService.dispose();
    AuthService.resetForTesting();
  });

  group('URL Shortener End-to-End', () {
    testWidgets('loads app and renders base components', (tester) async {
      await tester.pumpWidget(
        LinkShortenerApp(
          config: testConfig,
          authService: testAuthService,
          urlService: testUrlService,
        ),
      );

      // Verify initial state
      expect(find.text('Link Shortener'), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('SHORTEN URL'), findsOneWidget);
      
      // Verify anonymous user notice
      expect(
        find.text('Links created by anonymous users expire after 3 months.'),
        findsOneWidget,
      );
    });
    
    testWidgets('handles theme changes correctly', (tester) async {
      await tester.pumpWidget(
        LinkShortenerApp(
          config: testConfig,
          authService: testAuthService,
          urlService: testUrlService,
        ),
      );

      // Verify theme is initialized
      final theme = Theme.of(tester.element(find.byType(MaterialApp)));
      expect(theme.brightness, Brightness.light);
    });

    testWidgets('handles responsive layout changes', (tester) async {
      await tester.pumpWidget(
        LinkShortenerApp(
          config: testConfig,
          authService: testAuthService,
          urlService: testUrlService,
        ),
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
        LinkShortenerApp(
          config: testConfig,
          authService: testAuthService,
          urlService: testUrlService,
        ),
      );

      // Verify features are displayed
      expect(find.text('Features'), findsOneWidget);
      expect(find.text('Fast & Reliable'), findsOneWidget);
      expect(find.text('Link Analytics'), findsOneWidget);
      expect(find.text('Custom Expiration'), findsOneWidget);
    });
  });
}
