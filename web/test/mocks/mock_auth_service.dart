import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:link_shortener/models/auth/oauth_provider.dart';
import 'package:link_shortener/models/auth/user.dart';
import 'package:link_shortener/models/auth/user_session.dart';
import 'package:link_shortener/services/auth_service.dart';


/// Mock implementation of AuthService for testing
class MockAuthService implements AuthService {
  final Map<String, dynamic> _storage = {};
  final StreamController<UserSession?> _authStateController = StreamController<UserSession?>.broadcast();
  UserSession? _currentSession;
  bool _isLocalStorageInitialized = false;
  
  // Keys for storage
  static const String _tokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _tokenExpiryKey = 'auth_token_expiry';
  static const String _userDataKey = 'auth_user_data';
  
  @override
  Stream<UserSession?> get authStateChanges => _authStateController.stream;
  
  @override
  UserSession? get currentSession => _currentSession;
  
  @override
  bool get isAuthenticated => _currentSession != null && !_currentSession!.isExpired;
  
  @override
  Future<void> initialize() async {
    await _loadPersistedSession();
  }
  
  @override
  Future<void> initLocalStorage() async {
    if (_isLocalStorageInitialized) return;
    
    // Mock the initialization process
    await Future.delayed(const Duration(milliseconds: 10));
    _isLocalStorageInitialized = true;
    
    if (kDebugMode) {
      print('Mock LocalStorage initialized');
    }
  }
  
  /// Mock implementation of handleOAuthCallback
  Future<UserSession> handleOAuthCallback(String code, String provider) async {
    final providerEnum = _getOAuthProviderFromString(provider);
    
    final user = User(
      id: provider == 'google' ? 1 : (provider == 'apple' ? 2 : 3),
      name: 'Test User',
      email: 'test@example.com',
      provider: providerEnum,
    );
    
    final session = UserSession(
      user: user,
      token: 'mock_token_${provider}_$code',
      refreshToken: 'mock_refresh_${provider}_$code',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
    
    // Save session
    await _persistSession(session);
    
    _currentSession = session;
    _authStateController.add(_currentSession);
    
    return session;
  }
  
  /// Mock implementation of signInWithOAuth
  @override
  Future<void> signInWithOAuth(OAuthProvider provider) async {
    // Just track that the method was called, don't actually make network requests
    if (kDebugMode) {
      print('Mock OAuth sign in with $provider');
    }
  }
  
  /// Mock implementation of signOut
  @override
  Future<void> signOut() async {
    _storage.clear();
    _currentSession = null;
    _authStateController.add(null);
  }
  
  /// Mock implementation of refreshToken
  @override
  Future<bool> refreshToken() async {
    if (_currentSession == null || _currentSession!.refreshToken == '') {
      return false;
    }
    
    // Create a new session with extended expiry
    final session = UserSession(
      user: _currentSession!.user,
      token: 'refreshed_${_currentSession!.token}',
      refreshToken: _currentSession!.refreshToken,
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
    
    await _persistSession(session);
    
    _currentSession = session;
    _authStateController.add(_currentSession);
    
    return true;
  }
  
  /// Mock implementation of getUserProfile
  @override
  Future<User?> getUserProfile() async => _currentSession?.user;
  
  /// Mock implementation of checkAuthentication
  @override
  Future<bool> checkAuthentication() async {
    await _loadPersistedSession();
    return isAuthenticated;
  }
  
  // Helper method for mocking persistence
  Future<void> _persistSession(UserSession session) async {
    _storage[_tokenKey] = session.token;
    _storage[_refreshTokenKey] = session.refreshToken;
    _storage[_tokenExpiryKey] = session.expiresAt.millisecondsSinceEpoch.toString();
    _storage[_userDataKey] = jsonEncode(session.user!.toJson());
  }
  
  // Helper method for loading persisted session
  Future<void> _loadPersistedSession() async {
    final token = _storage[_tokenKey];
    final refreshToken = _storage[_refreshTokenKey];
    final expiryTimeMsString = _storage[_tokenExpiryKey];
    final userData = _storage[_userDataKey];
    
    if (token == null || refreshToken == null || expiryTimeMsString == null || userData == null) {
      return;
    }
    
    final expiryTimeMs = int.parse(expiryTimeMsString);
    final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiryTimeMs);
    
    if (DateTime.now().isAfter(expiryTime)) {
      return;
    }
    
    final user = User.fromJson(jsonDecode(userData));
    _currentSession = UserSession(
      user: user,
      token: token,
      refreshToken: refreshToken,
      expiresAt: expiryTime,
    );
    
    _authStateController.add(_currentSession);
  }
  
  @override
  Future<Map<String, String>> getAuthHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    if (isAuthenticated) {
      headers['Authorization'] = 'Bearer ${_currentSession!.token}';
    }
    
    return headers;
  }
  
  // Helper method to convert string to OAuthProvider
  OAuthProvider _getOAuthProviderFromString(String provider) {
    switch (provider) {
      case 'google':
        return OAuthProvider.google;
      case 'apple':
        return OAuthProvider.apple;
      case 'github':
        return OAuthProvider.github;
      default:
        return OAuthProvider.google;
    }
  }
  
  @override
  void dispose() {
    _authStateController.close();
  }

  @override
  Future<void> saveSession(UserSession session) {
    // TODO: implement saveSession
    throw UnimplementedError();
  }
}
