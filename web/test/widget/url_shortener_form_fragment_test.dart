import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link_shortener/services/url_service.dart';
import 'package:link_shortener/widgets/url_shortener_form.dart';
import '../mock/url_service_mock.dart';

void main() {
  group('URL Shortener Form URL Fragment Handling', () {
    late MockUrlService mockUrlService;

    setUp(() {
      mockUrlService = MockUrlService(
        delay: const Duration(milliseconds: 100),
      );
    });

    testWidgets('accepts and validates URL with fragment correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UrlShortenerForm(
              urlService: mockUrlService,
            ),
          ),
        ),
      );

      // Test URL with fragment
      const testUrlWithFragment = 'https://truewebber.com/about?t=1#blah';
      
      // Enter the URL with fragment
      await tester.enterText(find.byType(TextFormField), testUrlWithFragment);
      await tester.pump();
      
      // Ensure it was validated correctly (no error)
      expect(find.text('Please enter a valid URL starting with http:// or https://'), findsNothing);
      
      // Submit the form
      await tester.tap(find.text('Shorten URL'));
      await tester.pump();
      
      // Check loading indicator appears
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Wait for the operation to complete
      await tester.pumpAndSettle();
      
      // Verify the URL with fragment was passed correctly to the service
      expect(mockUrlService.lastShortenedUrl, equals(testUrlWithFragment));
    });
    
    testWidgets('successfully shortens URL with fragment', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UrlShortenerForm(
              urlService: mockUrlService,
            ),
          ),
        ),
      );

      // Test URL with fragment
      const testUrlWithFragment = 'https://example.com/page?param=1#section';
      
      // Enter the URL with fragment
      await tester.enterText(find.byType(TextFormField), testUrlWithFragment);
      
      // Submit the form
      await tester.tap(find.text('Shorten URL'));
      await tester.pump();
      
      // Wait for the operation to complete
      await tester.pumpAndSettle();
      
      // Verify success message and shortened URL display
      expect(find.text('URL shortened successfully!'), findsOneWidget);
      
      // Verify the original URL with fragment was passed to the service
      expect(mockUrlService.lastShortenedUrl, equals(testUrlWithFragment));
    });
  });
}
