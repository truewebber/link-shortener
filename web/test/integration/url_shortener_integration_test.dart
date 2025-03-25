import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link_shortener/main.dart';
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
    // Очистка таймеров и ресурсов
    testUrlService.dispose();
    testAuthService.dispose();
  });
  
  group('URL Shortener Integration', () {
    testWidgets('verifies app loads correctly with all components', (tester) async {
      await tester.pumpWidget(
        LinkShortenerApp(
          config: testConfig,
          authService: testAuthService,
          urlService: testUrlService,
        ),
      );
      await tester.pumpAndSettle();
      
      // Verify app title
      expect(find.text('Link Shortener'), findsOneWidget);
      
      // Verify URL input field is present
      expect(find.byType(TextFormField), findsOneWidget);
      
      // Verify shorten button is present
      expect(find.text('Shorten URL'), findsOneWidget);
      
      // Verify anonymous user notice
      expect(
        find.text('Links created by anonymous users expire after 3 months.'),
        findsOneWidget,
      );
    });
    
    testWidgets('verifies features section is displayed', (tester) async {
      await tester.pumpWidget(
        LinkShortenerApp(
          config: testConfig,
          authService: testAuthService,
          urlService: testUrlService,
        ),
      );
      await tester.pumpAndSettle();
      
      // Verify features section
      expect(find.text('Features'), findsOneWidget);
      
      // Verify feature items
      expect(find.text('Fast & Reliable'), findsOneWidget);
      expect(find.text('Link Analytics'), findsOneWidget);
      expect(find.text('Custom Expiration'), findsOneWidget);
    });
    
    testWidgets('verifies responsive layout in different screen sizes', (tester) async {
      await tester.pumpWidget(
        LinkShortenerApp(
          config: testConfig,
          authService: testAuthService,
          urlService: testUrlService,
        ),
      );
      await tester.pumpAndSettle();
      
      // Test desktop size
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pump();
      expect(find.byType(AppBar), findsOneWidget);
      
      // Test mobile size
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pump();
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
