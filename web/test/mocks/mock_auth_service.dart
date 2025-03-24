import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/src/widgets/framework.dart';
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
  
  /// Mock implementation of getUserProfile
  @override
  Future<User?> getUserProfile() async => _currentSession?.user;

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
  void dispose() {
    _authStateController.close();
  }

  @override
  Future<void> saveSession(UserSession session) {
    // TODO: implement saveSession
    throw UnimplementedError();
  }

  @override
  Future<Map<String, String>> getAuthHeaders({BuildContext? context}) {
    // TODO: implement getAuthHeaders
    throw UnimplementedError();
  }

  @override
  Future<bool> refreshToken({BuildContext? context}) {
    // TODO: implement refreshToken
    throw UnimplementedError();
  }

  @override
  Future<void> signInWithOAuth(OAuthProvider provider, {BuildContext? context}) {
    // TODO: implement signInWithOAuth
    throw UnimplementedError();
  }

  @override
  Future<AuthResult> getUserProfileWithAuthStatus({BuildContext? context}) {
    // TODO: implement getUserProfileWithAuthStatus
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> handleOAuthSuccessCallback(Uri uri) {
    // TODO: implement handleOAuthSuccessCallback
    throw UnimplementedError();
  }

  @override
  Future<void> signOut({BuildContext? context}) {
    // TODO: implement signOut
    throw UnimplementedError();
  }
}
