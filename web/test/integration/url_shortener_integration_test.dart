import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late TestAppConfig testConfig;
  
  setUp(() {
    testConfig = TestAppConfig();
  });
  
  group('URL Shortener Integration', () {
    testWidgets('completes URL shortening flow successfully', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          child: const MyApp(),
        ),
      );
      
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
    });
    
    testWidgets('handles invalid URL input', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          child: const MyApp(),
        ),
      );
      
      // Enter invalid URL
      const invalidUrl = 'not-a-url';
      await tester.enterText(find.byType(TextFormField), invalidUrl);
      
      // Submit form
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      // Verify error message
      expect(
        find.text('Please enter a valid URL'),
        findsOneWidget,
      );
    });
    
    testWidgets('handles API errors gracefully', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          child: const MyApp(),
        ),
      );
      
      // Enter URL
      const longUrl = 'https://example.com/very/long/url';
      await tester.enterText(find.byType(TextFormField), longUrl);
      
      // Simulate API error
      testConfig.simulateApiError = true;
      
      // Submit form
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      // Wait for API response
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      
      // Verify error message
      expect(
        find.text('Failed to shorten URL. Please try again.'),
        findsOneWidget,
      );
    });
    
    testWidgets('handles network errors gracefully', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          child: const MyApp(),
        ),
      );
      
      // Enter URL
      const longUrl = 'https://example.com/very/long/url';
      await tester.enterText(find.byType(TextFormField), longUrl);
      
      // Simulate network error
      testConfig.simulateNetworkError = true;
      
      // Submit form
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      // Wait for API response
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      
      // Verify error message
      expect(
        find.text('Network error. Please check your connection.'),
        findsOneWidget,
      );
    });
    
    testWidgets('handles rate limiting gracefully', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          child: const MyApp(),
        ),
      );
      
      // Enter URL
      const longUrl = 'https://example.com/very/long/url';
      await tester.enterText(find.byType(TextFormField), longUrl);
      
      // Simulate rate limit error
      testConfig.simulateRateLimitError = true;
      
      // Submit form
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      // Wait for API response
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      
      // Verify error message
      expect(
        find.text('Too many requests. Please try again later.'),
        findsOneWidget,
      );
    });
    
    testWidgets('maintains state after error recovery', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          config: testConfig,
          child: const MyApp(),
        ),
      );
      
      // Enter URL
      const longUrl = 'https://example.com/very/long/url';
      await tester.enterText(find.byType(TextFormField), longUrl);
      
      // Simulate API error
      testConfig.simulateApiError = true;
      
      // Submit form
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      // Wait for API response
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      
      // Clear error state
      testConfig.simulateApiError = false;
      
      // Submit form again
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      // Wait for API response
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      
      // Verify success state
      expect(find.text('URL shortened successfully!'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });
  });
}
