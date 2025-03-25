import 'package:flutter_test/flutter_test.dart';
import 'package:link_shortener/models/auth/oauth_provider.dart';
import 'package:link_shortener/models/auth/user.dart';
import 'package:link_shortener/models/auth/user_session.dart';
import 'package:mockito/mockito.dart';

import '../mocks/auth_service.generate.mocks.dart';

void main() {
  group('AuthService', () {
    late MockAuthService authService;

    setUp(() {
      authService = MockAuthService();
    });

    test('should initially have no session', () {
      when(authService.currentSession).thenReturn(null);
      when(authService.isAuthenticated).thenReturn(false);

      expect(authService.currentSession, isNull);
      expect(authService.isAuthenticated, isFalse);
    });

    test('should authenticate with OAuth callback', () async {
      const mockUser = User(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        provider: OAuthProvider.google,
      );
      final mockSession = UserSession(
        user: mockUser,
        token: 'mock_token_google_test_code',
        refreshToken: 'mock_refresh_google_test_code',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(authService.handleOAuthSuccessCallback(any)).thenAnswer((_) async => {
        'access_token': 'mock_token_google_test_code',
        'refresh_token': 'mock_refresh_google_test_code',
        'access_token_expiry_ms': DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch,
        'user': {
          'id': 1,
          'name': 'Test User',
          'email': 'test@example.com',
          'provider': 'google',
        },
      });
      when(authService.currentSession).thenReturn(mockSession);
      when(authService.isAuthenticated).thenReturn(true);
      
      final result = await authService.handleOAuthSuccessCallback(Uri.parse('https://example.com/callback?code=test_code'));
      
      expect(authService.currentSession, isNotNull);
      expect(authService.isAuthenticated, isTrue);
      expect(result['access_token'], contains('mock_token_google_test_code'));
      expect(result['refresh_token'], contains('mock_refresh_google_test_code'));
      expect(result['user']['name'], 'Test User');
      expect(result['user']['email'], 'test@example.com');
      expect(result['user']['provider'], 'google');
    });

    test('should persist and load session', () async {
      const mockUser = User(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        provider: OAuthProvider.google,
      );
      final mockSession = UserSession(
        user: mockUser,
        token: 'mock_token',
        refreshToken: 'mock_refresh',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(authService.saveSession(any)).thenAnswer((_) async {});
      when(authService.currentSession).thenReturn(mockSession);
      when(authService.isAuthenticated).thenReturn(true);
      
      await authService.saveSession(mockSession);
      
      expect(authService.isAuthenticated, isTrue);
      expect(authService.currentSession?.user?.email, 'test@example.com');
    });

    test('should sign out successfully', () async {
      when(authService.signOut()).thenAnswer((_) async {});
      when(authService.currentSession).thenReturn(null);
      when(authService.isAuthenticated).thenReturn(false);
      
      await authService.signOut();
      
      expect(authService.currentSession, isNull);
      expect(authService.isAuthenticated, isFalse);
    });

    test('should refresh token', () async {
      const mockUser = User(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        provider: OAuthProvider.apple,
      );
      final originalSession = UserSession(
        user: mockUser,
        token: 'original_token',
        refreshToken: 'refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
      final refreshedSession = UserSession(
        user: mockUser,
        token: 'refreshed_token',
        refreshToken: 'refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(authService.saveSession(any)).thenAnswer((_) async {});
      when(authService.refreshToken()).thenAnswer((_) async => true);
      when(authService.currentSession).thenReturn(refreshedSession);
      
      await authService.saveSession(originalSession);
      final refreshSuccessful = await authService.refreshToken();
      
      expect(refreshSuccessful, isTrue);
      expect(authService.currentSession?.token, isNot(equals(originalSession.token)));
      expect(authService.currentSession?.token, contains('refreshed_'));
    });

    test('should get auth headers', () async {
      when(authService.getAuthHeaders()).thenAnswer((_) async => {
        'Content-Type': 'application/json',
      });
      
      var headers = await authService.getAuthHeaders();
      expect(headers['Content-Type'], 'application/json');
      expect(headers.containsKey('Authorization'), isFalse);
      
      when(authService.getAuthHeaders()).thenAnswer((_) async => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer mock_token',
      });
      
      headers = await authService.getAuthHeaders();
      
      expect(headers['Content-Type'], 'application/json');
      expect(headers.containsKey('Authorization'), isTrue);
      expect(headers['Authorization'], startsWith('Bearer '));
    });

    test('should emit auth state changes', () async {
      const mockUser = User(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        provider: OAuthProvider.google,
      );
      final mockSession = UserSession(
        user: mockUser,
        token: 'mock_token',
        refreshToken: 'mock_refresh',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(authService.authStateChanges).thenAnswer((_) => Stream.fromIterable([mockSession, null]));
      
      final states = <UserSession?>[];
      final subscription = authService.authStateChanges.listen(states.add);
      
      await Future.delayed(Duration.zero);
      await subscription.cancel();
      
      expect(states.length, 2);
      expect(states[0], isNotNull);
      expect(states[1], isNull);
    });
  });
}
