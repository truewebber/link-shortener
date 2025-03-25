import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link_shortener/models/auth/oauth_provider.dart';
import 'package:link_shortener/models/auth/user.dart';
import 'package:link_shortener/models/auth/user_session.dart';
import 'package:link_shortener/models/short_url.dart';
import 'package:link_shortener/screens/url_management_screen.dart';
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
  
  Future<void> pumpUrlManagementScreen(WidgetTester tester, {bool isAuthenticated = true}) async {
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
        home: UrlManagementScreen(
          authService: testAuthService,
          urlService: testUrlService,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }
  
  group('UrlManagementScreen', () {
    testWidgets('should show loading state initially', (tester) async {
      when(testUrlService.getUserUrls(context: anyNamed('context')))
          .thenAnswer((_) => Future.delayed(const Duration(seconds: 1)));

      await pumpUrlManagementScreen(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show empty state when no URLs', (tester) async {
      when(testUrlService.getUserUrls(context: anyNamed('context')))
          .thenAnswer((_) => Future.value([]));

      await pumpUrlManagementScreen(tester);

      expect(find.text('No URLs found'), findsOneWidget);
      expect(find.text('Create your first shortened URL'), findsOneWidget);
    });

    testWidgets('should show URLs when available', (tester) async {
      final urls = [
        ShortUrl(
          originalUrl: 'https://example.com',
          shortId: 'abc123',
          shortUrl: 'https://short.url/abc123',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(days: 30)),
          userId: '1',
        ),
      ];

      when(testUrlService.getUserUrls(context: anyNamed('context')))
          .thenAnswer((_) => Future.value(urls));

      await pumpUrlManagementScreen(tester);

      expect(find.text('https://example.com'), findsOneWidget);
      expect(find.text('https://short.url/abc123'), findsOneWidget);
    });

    testWidgets('should handle URL deletion', (tester) async {
      final url = ShortUrl(
        originalUrl: 'https://example.com',
        shortId: 'abc123',
        shortUrl: 'https://short.url/abc123',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 30)),
        userId: '1',
      );

      when(testUrlService.getUserUrls(context: anyNamed('context')))
          .thenAnswer((_) => Future.value([url]));
      when(testUrlService.deleteUrl('abc123', context: anyNamed('context')))
          .thenAnswer((_) => Future.value(true));

      await pumpUrlManagementScreen(tester);

      // Open delete dialog
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Verify dialog content
      expect(find.text('Delete URL'), findsOneWidget);
      expect(find.text('Are you sure you want to delete the shortened URL for "https://example.com"?'), findsOneWidget);

      // Confirm deletion
      await tester.tap(find.text('DELETE'));
      await tester.pumpAndSettle();

      // Verify URL is deleted
      verify(testUrlService.deleteUrl('abc123', context: anyNamed('context'))).called(1);
    });

    testWidgets('should handle URL copy', (tester) async {
      final url = ShortUrl(
        originalUrl: 'https://example.com',
        shortId: 'abc123',
        shortUrl: 'https://short.url/abc123',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 30)),
        userId: '1',
      );

      when(testUrlService.getUserUrls(context: anyNamed('context')))
          .thenAnswer((_) => Future.value([url]));

      await pumpUrlManagementScreen(tester);

      // Tap copy button
      await tester.tap(find.byIcon(Icons.copy));
      await tester.pumpAndSettle();

      // Verify copy feedback
      expect(find.text('URL copied to clipboard'), findsOneWidget);
    });

    testWidgets('should handle error state', (tester) async {
      when(testUrlService.getUserUrls(context: anyNamed('context')))
          .thenThrow(Exception('Failed to load URLs'));

      await pumpUrlManagementScreen(tester);

      expect(find.text('Failed to load URLs: Exception: Failed to load URLs'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      // Tap retry button
      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();

      // Verify retry attempt
      verify(testUrlService.getUserUrls(context: anyNamed('context'))).called(2);
    });

    testWidgets('should handle unauthenticated state', (tester) async {
      await pumpUrlManagementScreen(tester, isAuthenticated: false);

      expect(find.text('Please sign in to view your URLs'), findsOneWidget);
    });
  });
} 