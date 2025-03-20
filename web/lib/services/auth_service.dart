import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:link_shortener/models/auth/oauth_provider.dart';
import 'package:link_shortener/models/auth/user.dart';

/// A simple demo authentication service.
/// In a real app, this would be replaced with actual OAuth implementation.
class AuthService {
  factory AuthService() => _instance;
  AuthService._internal();
  // Singleton instance
  static final AuthService _instance = AuthService._internal();
  
  // Authentication state controller
  final StreamController<UserSession?> _authStateController = StreamController<UserSession?>.broadcast();
  Stream<UserSession?> get authStateChanges => _authStateController.stream;
  
  // Current user session
  UserSession? _currentSession;
  UserSession? get currentSession => _currentSession;
  bool get isAuthenticated => _currentSession != null && !_currentSession!.isExpired;
  
  // Method to sign in with an OAuth provider
  Future<UserSession> signInWithOAuth(OAuthProvider provider) async {
    if (kDebugMode) {
      print('Signing in with ${provider.name}');
    }
    
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Create a demo user session
    final session = _createDemoSession(provider);
    _currentSession = session;
    
    // Notify listeners
    _authStateController.add(session);
    
    return session;
  }
  
  // Method to sign out
  Future<void> signOut() async {
    if (kDebugMode) {
      print('Signing out');
    }
    
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    _currentSession = null;
    
    // Notify listeners
    _authStateController.add(null);
  }
  
  // Helper to create a demo user session based on provider
  UserSession _createDemoSession(OAuthProvider provider) {
    // Create different demo users based on provider
    final User user;
    
    switch (provider) {
      case OAuthProvider.google:
        user = const User(
          id: 1,
          name: 'John Doe',
          email: 'john.doe@example.com',
          provider: OAuthProvider.google,
        );
        break;
      case OAuthProvider.apple:
        user = const User(
          id: 2,
          name: 'Jane Smith',
          email: 'jane.smith@example.com',
          provider: OAuthProvider.apple,
        );
        break;
      case OAuthProvider.github:
        user = const User(
          id: 3,
          name: 'Dev User',
          email: 'dev.user@example.com',
          provider: OAuthProvider.github,
        );
        break;
    }
    
    // Create session with a token that expires in 1 hour
    return UserSession(
      user: user,
      token: 'demo_token_${DateTime.now().millisecondsSinceEpoch}',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }
  
  // Dispose method to clean up resources
  void dispose() {
    _authStateController.close();
  }
}
