import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link_shortener/models/auth/oauth_provider.dart';
import 'package:link_shortener/models/auth/user.dart';
import 'package:link_shortener/models/auth/user_session.dart';
import 'package:link_shortener/screens/auth_screen.dart';
import 'package:link_shortener/screens/home_screen.dart';
import 'package:link_shortener/screens/profile_screen.dart';
import 'package:link_shortener/widgets/feature_section.dart';
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
    // Убедимся, что ресурсы очищены после каждого теста
    testAuthService.dispose();
    testUrlService.dispose();
  });
  
  Future<void> pumpHomeScreen(WidgetTester tester, {bool isAuthenticated = false}) async {
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
        home: HomeScreen(
          authService: testAuthService,
          urlService: testUrlService,
        ),
      ),
    );
    await tester.pump();
  }
  
  group('HomeScreen', () {
    testWidgets('should show different content for authenticated users', (tester) async {
      await pumpHomeScreen(tester, isAuthenticated: true);

      // Verify authenticated user content
      expect(find.text('Welcome back, Test User!'), findsOneWidget);
      expect(find.text('You now have access to additional features including custom expiration times and link management.'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('should show content for anonymous users', (tester) async {
      await pumpHomeScreen(tester);

      // Verify anonymous user content
      expect(find.text('Sign In for More Features'), findsOneWidget);
      expect(find.text('Links created by anonymous users expire after 3 months.'), findsOneWidget);
    });

    testWidgets('should handle navigation to auth screen', (tester) async {
      await pumpHomeScreen(tester);

      // Tap sign in button
      await tester.tap(find.text('Sign In for More Features'));
      await tester.pumpAndSettle();

      // Verify navigation to auth screen
      expect(find.byType(AuthScreen), findsOneWidget);
    });

    testWidgets('should handle navigation to profile screen', (tester) async {
      await pumpHomeScreen(tester, isAuthenticated: true);

      // Tap profile button
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Verify navigation to profile screen
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('should display feature section', (tester) async {
      await pumpHomeScreen(tester);

      // Verify feature section is present
      expect(find.byType(FeatureSection), findsOneWidget);
    });

    testWidgets('should handle URL shortening form', (tester) async {
      await pumpHomeScreen(tester);

      // Verify URL shortening form is present
      expect(find.byType(UrlShortenerForm), findsOneWidget);
    });

    testWidgets('should maintain responsive layout', (tester) async {
      await pumpHomeScreen(tester);

      // Test desktop layout
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pump();

      // Verify desktop layout elements
      expect(find.byType(Row), findsWidgets);

      // Test mobile layout
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pump();

      // Verify mobile layout elements
      expect(find.byType(Column), findsWidgets);
    });
  });
}
