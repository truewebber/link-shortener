import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link_shortener/widgets/url_shortener_form.dart';

import '../mocks/mock_auth_service.dart';
import '../test_helper.dart';

void main() {
  late TestAppConfig testConfig;
  late MockAuthService testAuthService;
  
  setUp(() {
    testConfig = TestAppConfig();
    testAuthService = MockAuthService();
  });
  
  group('UrlShortenerForm', () {
    testWidgets('validates URL input correctly', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          authService: testAuthService,
          child: const UrlShortenerForm(),
        ),
      );
      
      // Test invalid URL
      await tester.enterText(
        find.byType(TextFormField),
        'invalid-url',
      );
      
      await tester.tap(find.text('SHORTEN URL'));
      await tester.pump();
      
      expect(find.text('Please enter a valid URL starting with http:// or https://'), findsOneWidget);
      
      // Test valid URL
      await tester.enterText(
        find.byType(TextFormField),
        'https://example.com',
      );
      
      await tester.tap(find.text('SHORTEN URL'));
      await tester.pump();
      
      expect(find.text('Please enter a valid URL starting with http:// or https://'), findsNothing);
    });
    
    testWidgets('shows anonymous user notice', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          child: const UrlShortenerForm(),
        ),
      );
      
      expect(
        find.text('Note: Links created by anonymous users expire after 3 months.'),
        findsOneWidget,
      );
    });
  });
}
