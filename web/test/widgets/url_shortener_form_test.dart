import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link_shortener/services/api_service.dart';
import 'package:mockito/mockito.dart';
import 'package:link_shortener/widgets/url_shortener_form.dart';
import '../test_helper.dart';

void main() {
  late MockApiService mockApiService;
  late TestAppConfig testConfig;
  
  setUp(() {
    mockApiService = MockApiService();
    testConfig = TestAppConfig();
  });
  
  group('UrlShortenerForm', () {
    testWidgets('validates URL input correctly', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
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
    
    testWidgets('shows loading indicator during API call', (tester) async {
      when(mockApiService.shortenUrl(any))
          .thenAnswer((_) => Future.delayed(
                const Duration(seconds: 1),
                () => 'https://short.url/abc123',
              ));
      
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          child: const UrlShortenerForm(),
        ),
      );
      
      await tester.enterText(
        find.byType(TextFormField),
        'https://example.com',
      );
      
      await tester.tap(find.text('SHORTEN URL'));
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      await tester.pump(const Duration(seconds: 2));
      
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('https://short.url/abc123'), findsOneWidget);
    });
    
    testWidgets('displays error message on API failure', (tester) async {
      when(mockApiService.shortenUrl(any))
          .thenThrow(ApiException('Failed to shorten URL'));
      
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          child: const UrlShortenerForm(),
        ),
      );
      
      await tester.enterText(
        find.byType(TextFormField),
        'https://example.com',
      );
      
      await tester.tap(find.text('SHORTEN URL'));
      await tester.pump();
      
      expect(find.text('Failed to shorten URL'), findsOneWidget);
    });
    
    testWidgets('copies shortened URL to clipboard', (tester) async {
      const shortUrl = 'https://short.url/abc123';
      when(mockApiService.shortenUrl(any))
          .thenAnswer((_) async => shortUrl);
      
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          child: const UrlShortenerForm(),
        ),
      );
      
      await tester.enterText(
        find.byType(TextFormField),
        'https://example.com',
      );
      
      await tester.tap(find.text('SHORTEN URL'));
      await tester.pump();
      
      await tester.tap(find.byIcon(Icons.copy));
      await tester.pump();
      
      expect(find.text('Copied to clipboard!'), findsOneWidget);
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
