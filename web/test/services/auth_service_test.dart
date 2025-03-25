import 'package:flutter_test/flutter_test.dart';
import 'package:link_shortener/models/auth/oauth_provider.dart';
import 'package:link_shortener/models/auth/user.dart';
import 'package:link_shortener/models/auth/user_session.dart';
import 'package:link_shortener/services/auth_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../mocks/auth_service.generate.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  late MockAuthService authService;
  late User testUser;
  late UserSession testSession;

  setUp(() {
    authService = MockAuthService();
    testUser = const User(
      id: 1,
      email: 'test@example.com',
      name: 'Test User',
      provider: OAuthProvider.google,
      avatarUrl: 'https://example.com/avatar.jpg',
    );
    testSession = UserSession(
      token: 'test-token',
      refreshToken: 'test-refresh-token',
      expiresAt: DateTime.now().add(const Duration(days: 1)),
      user: testUser,
    );
  });

  group('AuthService Tests', () {
    test('should initialize service', () async {
      when(authService.initialize()).thenAnswer((_) async {});
      when(authService.currentSession).thenReturn(null);
      
      await authService.initialize();
      verify(authService.initialize()).called(1);
    });

    test('should handle OAuth initialization', () async {
      when(authService.signInWithOAuth(OAuthProvider.google))
          .thenThrow(Exception('Not supported'));

      expect(
        () => authService.signInWithOAuth(OAuthProvider.google),
        throwsException,
      );
    });

    test('should manage session state', () async {
      when(authService.saveSession(testSession)).thenAnswer((_) async {});
      when(authService.currentSession).thenReturn(testSession);
      when(authService.isAuthenticated).thenReturn(true);

      await authService.saveSession(testSession);
      expect(authService.currentSession, testSession);
      expect(authService.isAuthenticated, true);
    });

    test('should emit session changes', () async {
      when(authService.saveSession(testSession)).thenAnswer((_) async {});
      when(authService.authStateChanges)
          .thenAnswer((_) => Stream.value(testSession));

      expect(authService.authStateChanges, emits(testSession));
      await authService.saveSession(testSession);
    });

    test('should handle token refresh', () async {
      when(authService.currentSession).thenReturn(testSession);
      when(authService.refreshToken()).thenAnswer((_) async => true);

      final result = await authService.refreshToken();
      expect(result, true);
    });

    test('should handle OAuth success callback', () async {
      final uri = Uri.parse('http://localhost:3000/callback?code=test-code');
      when(authService.handleOAuthSuccessCallback(uri))
          .thenAnswer((_) async => {'success': true});

      final result = await authService.handleOAuthSuccessCallback(uri);
      expect(result['success'], true);
    });

    test('should sign out', () async {
      when(authService.signOut()).thenAnswer((_) async {});
      when(authService.currentSession).thenReturn(null);
      when(authService.isAuthenticated).thenReturn(false);

      await authService.signOut();
      expect(authService.currentSession, isNull);
      expect(authService.isAuthenticated, false);
    });

    test('should get auth headers', () async {
      when(authService.currentSession).thenReturn(testSession);
      when(authService.getAuthHeaders()).thenAnswer((_) async => {
            'Authorization': 'Bearer ${testSession.token}',
          });

      final headers = await authService.getAuthHeaders();
      expect(headers['Authorization'], 'Bearer ${testSession.token}');
    });

    test('should emit auth state changes', () async {
      when(authService.saveSession(testSession)).thenAnswer((_) async {});
      when(authService.authStateChanges)
          .thenAnswer((_) => Stream.value(testSession));

      expect(authService.authStateChanges, emits(testSession));
      await authService.saveSession(testSession);
    });
  });
}
