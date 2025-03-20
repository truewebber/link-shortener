import 'package:flutter_test/flutter_test.dart';
import 'package:link_shortener/models/auth/oauth_provider.dart';
import 'package:link_shortener/services/auth_service.dart';

void main() {
  late AuthService authService;

  setUp(() {
    authService = AuthService();
  });

  group('AuthService', () {
    test('initial state should be unauthenticated', () {
      expect(authService.isAuthenticated, isFalse);
      expect(authService.currentSession, isNull);
    });

    test('signInWithOAuth should create a user session', () async {
      final session = await authService.signInWithOAuth(OAuthProvider.google);
      
      expect(authService.isAuthenticated, isTrue);
      expect(authService.currentSession, equals(session));
      expect(session.user.provider, equals(OAuthProvider.google));
      expect(session.token, startsWith('demo_token_'));
      expect(session.isExpired, isFalse);
    });

    test('signInWithOAuth should return different users for different providers', () async {
      final googleSession = await authService.signInWithOAuth(OAuthProvider.google);
      await authService.signOut();
      
      final appleSession = await authService.signInWithOAuth(OAuthProvider.apple);
      await authService.signOut();
      
      final githubSession = await authService.signInWithOAuth(OAuthProvider.github);
      
      expect(googleSession.user.id, isNot(equals(appleSession.user.id)));
      expect(googleSession.user.id, isNot(equals(githubSession.user.id)));
      expect(appleSession.user.id, isNot(equals(githubSession.user.id)));
      
      expect(googleSession.user.provider, equals(OAuthProvider.google));
      expect(appleSession.user.provider, equals(OAuthProvider.apple));
      expect(githubSession.user.provider, equals(OAuthProvider.github));
    });

    test('signOut should clear the current session', () async {
      await authService.signInWithOAuth(OAuthProvider.google);
      expect(authService.isAuthenticated, isTrue);
      
      await authService.signOut();
      expect(authService.isAuthenticated, isFalse);
      expect(authService.currentSession, isNull);
    });

    test('authStateChanges should emit session events', () async {
      // Setup stream listener
      final events = <dynamic>[];
      final subscription = authService.authStateChanges.listen(events.add);
      
      // Perform auth actions
      await authService.signInWithOAuth(OAuthProvider.google);
      await authService.signOut();
      await authService.signInWithOAuth(OAuthProvider.apple);
      
      // Give stream time to emit all events
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Cleanup
      await subscription.cancel();
      
      // Verify events
      expect(events.length, equals(3));
      expect(events[0], isNotNull);
      expect(events[1], isNull);
      expect(events[2], isNotNull);
      
      if (events[0] != null && events[2] != null) {
        expect(events[0].user.provider, equals(OAuthProvider.google));
        expect(events[2].user.provider, equals(OAuthProvider.apple));
      }
    });
  });
}
