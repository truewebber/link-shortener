import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link_shortener/main.dart';
import 'package:link_shortener/services/url_service.dart';
import '../mocks/mock_auth_service.dart';
import '../mocks/service_factory.dart';
import '../test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late TestAppConfig testConfig;
  late MockAuthService testAuthService;
  late UrlService testUrlService;
  
  setUp(() {
    testConfig = TestAppConfig();
    testServiceFactory.reset();
    testAuthService = testServiceFactory.provideAuthService() as MockAuthService;
    testUrlService = testServiceFactory.provideUrlService();
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
      
      // Verify app title
      expect(find.text('Link Shortener'), findsOneWidget);
      
      // Verify URL input field is present
      expect(find.byType(TextFormField), findsOneWidget);
      
      // Verify shorten button is present
      expect(find.text('SHORTEN URL'), findsOneWidget);
      
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
