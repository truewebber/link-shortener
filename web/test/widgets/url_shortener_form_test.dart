import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link_shortener/models/auth/oauth_provider.dart';
import 'package:link_shortener/models/auth/user.dart';
import 'package:link_shortener/models/auth/user_session.dart';
import 'package:link_shortener/widgets/url_shortener_form.dart';
import 'package:mockito/mockito.dart';

import '../mocks/auth_service.generate.mocks.dart';
import '../mocks/url_service.generate.mocks.dart';

void main() {
  late MockAuthService testAuthService;
  late MockUrlService testUrlService;

  setUp(() {
    testAuthService = MockAuthService();
    testUrlService = MockUrlService();
  });

  tearDown(() {
    testAuthService.dispose();
    testUrlService.dispose();
  });

  Future<void> pumpUrlShortenerForm(WidgetTester tester, {bool isAuthenticated = false}) async {
    if (isAuthenticated) {
      final session = UserSession(
        user: const User(
          id: 1,
          name: 'Test User',
          email: 'test@example.com',
          provider: OAuthProvider.google,
        ),
        token: 'test-token',
        refreshToken: 'test-refresh-token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
      when(testAuthService.currentSession).thenReturn(session);
      when(testAuthService.isAuthenticated).thenReturn(true);
    } else {
      when(testAuthService.currentSession).thenReturn(null);
      when(testAuthService.isAuthenticated).thenReturn(false);
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UrlShortenerForm(
            isAuthenticated: isAuthenticated,
            urlService: testUrlService,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('UrlShortenerForm', () {
    testWidgets('should validate URL format in real-time', (tester) async {
      await pumpUrlShortenerForm(tester);

      // Enter invalid URL
      await tester.enterText(find.byType(TextFormField), 'invalid-url');
      await tester.pump();

      // Verify error message is shown
      expect(find.text('Please enter a valid URL starting with http:// or https://'), findsOneWidget);

      // Enter valid URL
      await tester.enterText(find.byType(TextFormField), 'https://example.com');
      await tester.pump();

      // Verify error message is removed
      expect(find.text('Please enter a valid URL starting with http:// or https://'), findsNothing);
    });

    testWidgets('should show loading state during URL shortening for anonymous users', (tester) async {
      await pumpUrlShortenerForm(tester);

      // Mock URL service to delay response
      when(testUrlService.shortenRestrictedUrl(any)).thenAnswer(
        (_) => Future.delayed(
          const Duration(seconds: 1),
          () => 'https://short.url/abc123',
        ),
      );

      // Enter valid URL and submit
      await tester.enterText(find.byType(TextFormField), 'https://example.com');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verify loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled, isFalse);

      // Wait for URL shortening to complete
      await tester.pumpAndSettle();
    });

    testWidgets('should show loading state during URL shortening for authenticated users', (tester) async {
      await pumpUrlShortenerForm(tester, isAuthenticated: true);

      // Mock URL service to delay response
      when(testUrlService.createShortUrl(
        url: anyNamed('url'),
        context: anyNamed('context'),
        ttl: anyNamed('ttl'),
      )).thenAnswer(
        (_) => Future.delayed(
          const Duration(seconds: 1),
          () => 'https://short.url/abc123',
        ),
      );

      // Enter valid URL and submit
      await tester.enterText(find.byType(TextFormField), 'https://example.com');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verify loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled, isFalse);

      // Wait for URL shortening to complete
      await tester.pumpAndSettle();
    });

    testWidgets('should display shortened URL with copy button for anonymous users', (tester) async {
      await pumpUrlShortenerForm(tester);

      // Mock URL service to return shortened URL
      when(testUrlService.shortenRestrictedUrl(any))
          .thenAnswer((_) => Future.value('https://short.url/abc123'));

      // Enter valid URL and submit
      await tester.enterText(find.byType(TextFormField), 'https://example.com');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify shortened URL is displayed
      expect(find.text('Your shortened URL:'), findsOneWidget);
      expect(find.text('https://short.url/abc123'), findsOneWidget);
      expect(find.byIcon(Icons.copy), findsOneWidget);
    });

    testWidgets('should display shortened URL with copy button for authenticated users', (tester) async {
      await pumpUrlShortenerForm(tester, isAuthenticated: true);

      // Mock URL service to return shortened URL
      when(testUrlService.createShortUrl(
        url: anyNamed('url'),
        context: anyNamed('context'),
        ttl: anyNamed('ttl'),
      )).thenAnswer((_) => Future.value('https://short.url/abc123'));

      // Enter valid URL and submit
      await tester.enterText(find.byType(TextFormField), 'https://example.com');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify shortened URL is displayed
      expect(find.text('Your shortened URL:'), findsOneWidget);
      expect(find.text('https://short.url/abc123'), findsOneWidget);
      expect(find.byIcon(Icons.copy), findsOneWidget);
    });

    testWidgets('should show error message for failed URL shortening', (tester) async {
      await pumpUrlShortenerForm(tester);

      // Mock URL service to throw error
      when(testUrlService.shortenRestrictedUrl(any))
          .thenThrow(Exception('Failed to shorten URL'));

      // Enter valid URL and submit
      await tester.enterText(find.byType(TextFormField), 'https://example.com');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify error message is shown in SnackBar
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Error: Exception: Failed to shorten URL'), findsOneWidget);
    });

    testWidgets('should maintain responsive layout', (tester) async {
      await pumpUrlShortenerForm(tester);

      // Test desktop layout
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pump();

      // Verify desktop layout elements
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      // Test mobile layout
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pump();

      // Verify mobile layout elements
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}
