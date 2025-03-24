import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link_shortener/widgets/url_shortener_form.dart';
import 'package:mockito/mockito.dart';

import '../mocks/url_service.generate.mocks.dart';

void main() {
  late MockUrlService urlService;
  late TestWidgetsFlutterBinding binding;

  setUp(() {
    binding = TestWidgetsFlutterBinding.ensureInitialized();
    urlService = MockUrlService();
  });

  tearDown(() {
    urlService.dispose();
  });

  Future<void> pumpUrlShortenerForm(WidgetTester tester, {bool isAuthenticated = false}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UrlShortenerForm(
            isAuthenticated: isAuthenticated,
            urlService: urlService,
          ),
        ),
      ),
    );
  }

  group('UrlShortenerForm', () {
    testWidgets('displays input field with placeholder', (tester) async {
      await pumpUrlShortenerForm(tester);
      await tester.pump();
      expect(find.text('Enter URL to shorten'), findsOneWidget);
      expect(find.text('Paste your long URL here'), findsOneWidget);
    });

    testWidgets('validates URL format in real-time', (tester) async {
      await pumpUrlShortenerForm(tester);

      // Enter invalid URL
      await tester.enterText(find.byType(TextFormField), 'invalid-url');
      await tester.pump();

      // Verify error message is shown
      expect(find.text('Please enter a valid URL'), findsOneWidget);

      // Enter valid URL
      await tester.enterText(find.byType(TextFormField), 'https://example.com');
      await tester.pump();

      // Verify error message is gone
      expect(find.text('Please enter a valid URL'), findsNothing);
    });

    testWidgets('shows loading state during URL shortening', (tester) async {
      final completer = Completer<String>();
      when(urlService.shortenUrl('https://example.com'))
          .thenAnswer((_) => completer.future);

      await pumpUrlShortenerForm(tester);

      // Enter valid URL
      await tester.enterText(find.byType(TextFormField), 'https://example.com');
      await tester.pump();

      // Submit form
      await tester.tap(find.text('SHORTEN URL'));
      await tester.pump();

      // Verify loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('SHORTEN URL'), findsNothing);

      // Complete the future
      completer.complete('https://short.url/abc123');
      await tester.pumpAndSettle();
    });

    testWidgets('displays shortened URL with copy button', (tester) async {
      when(urlService.shortenUrl('https://example.com'))
          .thenAnswer((_) => Future.value('https://short.url/abc123'));

      await pumpUrlShortenerForm(tester);

      // Enter valid URL
      await tester.enterText(find.byType(TextFormField), 'https://example.com');
      await tester.pump();

      // Submit form
      await tester.tap(find.text('SHORTEN URL'));
      await tester.pumpAndSettle();

      // Verify shortened URL is displayed
      expect(find.text('https://short.url/abc123'), findsOneWidget);
      expect(find.byIcon(Icons.copy), findsOneWidget);
    });

    testWidgets('shows error message for failed URL shortening', (tester) async {
      when(urlService.shortenUrl('https://example.com'))
          .thenThrow(Exception('Failed to shorten URL'));

      await pumpUrlShortenerForm(tester);

      // Enter valid URL and submit form
      await tester.enterText(find.byType(TextFormField), 'https://example.com');
      await tester.pump();

      // Submit form
      await tester.tap(find.text('SHORTEN URL'));
      await tester.pumpAndSettle();

      expect(find.text('Failed to shorten URL. Please try again.'), findsOneWidget);
    });

    testWidgets('maintains responsive layout across different screen sizes', (tester) async {
      when(urlService.shortenUrl('https://example.com'))
          .thenAnswer((_) => Future.value('https://short.url/abc123'));
      
      await pumpUrlShortenerForm(tester);

      // Test mobile layout
      await binding.setSurfaceSize(const Size(400, 800));
      await tester.pump();
      
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      // Test desktop layout
      await binding.setSurfaceSize(const Size(1200, 800));
      await tester.pump();
      
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      // Reset surface size
      await binding.setSurfaceSize(null);
      await tester.pump();
    });
  });
}
