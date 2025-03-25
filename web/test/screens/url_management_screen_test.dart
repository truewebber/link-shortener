import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    
    // Set up clipboard mock
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/clipboard'),
      (methodCall) async {
        if (methodCall.method == 'setData') {
          return true;
        }
        return null;
      },
    );
  });
  
  tearDown(() {
    testAuthService.dispose();
    testUrlService.dispose();
    
    // Clear clipboard mock
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/clipboard'),
      null,
    );
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
        scaffoldMessengerKey: GlobalKey<ScaffoldMessengerState>(),
        home: UrlManagementScreen(
          authService: testAuthService,
          urlService: testUrlService,
        ),
      ),
    );
  }
  
  group('UrlManagementScreen', () {
    testWidgets('should show loading state initially', (tester) async {
      when(testUrlService.getUserUrls(context: anyNamed('context')))
          .thenAnswer((_) => Future.delayed(const Duration(seconds: 1)));

      await pumpUrlManagementScreen(tester);
      
      // Loading state should be visible immediately
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Wait for the async operation to complete
      await tester.pumpAndSettle();
      
      // Loading state should be gone
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should show empty state when no URLs', (tester) async {
      when(testUrlService.getUserUrls(context: anyNamed('context')))
          .thenAnswer((_) => Future.value([]));

      await pumpUrlManagementScreen(tester);
      await tester.pump(); // Wait for first frame
      await tester.pumpAndSettle(); // Wait for async operation to complete

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
      await tester.pump(); // Wait for first frame
      await tester.pumpAndSettle(); // Wait for async operation to complete

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
      await tester.pump(); // Wait for first frame
      await tester.pumpAndSettle(); // Wait for async operation to complete

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

    testWidgets('should handle error state', (tester) async {
      when(testUrlService.getUserUrls(context: anyNamed('context')))
          .thenThrow(Exception('Failed to load URLs'));

      await pumpUrlManagementScreen(tester);
      await tester.pumpAndSettle(); // Wait for error state to be rendered

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