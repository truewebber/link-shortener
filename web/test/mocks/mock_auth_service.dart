import 'dart:async';

import 'package:link_shortener/models/auth/oauth_provider.dart';
import 'package:link_shortener/models/auth/user.dart';
import 'package:link_shortener/services/auth_service.dart';

/// Mock implementation of AuthService for testing
class MockAuthService implements AuthService {
  // Controller for auth state changes
  final StreamController<UserSession?> _authStateController = StreamController<UserSession?>.broadcast();
  
  // Mock user session
  UserSession? _mockUserSession;
  
  // Test configuration
  Duration? mockAuthenticationDelay;
  bool mockShouldFail = false;
  String mockErrorMessage = 'Authentication failed';
  
  @override
  Stream<UserSession?> get authStateChanges => _authStateController.stream;
  
  @override
  UserSession? get currentSession => _mockUserSession;
  
  @override
  bool get isAuthenticated => _mockUserSession != null && !_mockUserSession!.isExpired;
  
  @override
  Future<UserSession> signInWithOAuth(OAuthProvider provider) async {
    // Add delay if configured
    if (mockAuthenticationDelay != null) {
      await Future.delayed(mockAuthenticationDelay!);
    }
    
    // Simulate failure if configured
    if (mockShouldFail) {
      throw Exception(mockErrorMessage);
    }
    
    // Create a mock session with test data
    final session = UserSession(
      user: User(
        id: 999,
        name: 'Test User',
        email: 'test@example.com',
        provider: provider,
      ),
      token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
    
    _mockUserSession = session;
    _authStateController.add(session);
    
    return session;
  }
  
  @override
  Future<void> signOut() async {
    _mockUserSession = null;
    _authStateController.add(null);
  }
  
  @override
  void dispose() {
    _authStateController.close();
  }
  
  // Helper method for tests to set a user session directly
  void setMockUserSession(UserSession? session) {
    _mockUserSession = session;
    _authStateController.add(session);
  }
}
