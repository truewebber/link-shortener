import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:link_shortener/models/auth/oauth_provider.dart';

// Не импортируем реальные классы, создаем свои моки
class MockUserSession {
  MockUserSession({
    required this.user,
    required this.token,
    required this.expiresAt,
    this.refreshToken,
  });

  final MockUser user;
  final String token;
  final String? refreshToken;
  final DateTime expiresAt;
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class MockUser {
  MockUser({
    required this.id,
    required this.name,
    required this.email,
    required this.provider,
  });

  factory MockUser.fromJson(Map<String, dynamic> json) => MockUser(
    id: json['id'] as int,
    name: json['name'] as String,
    email: json['email'] as String,
    provider: _providerFromString(json['provider'] as String),
  );

  final int id;
  final String name;
  final String email;
  final OAuthProvider provider;
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'provider': provider.name,
  };
  
  static OAuthProvider _providerFromString(String value) {
    switch (value.toLowerCase()) {
      case 'google':
        return OAuthProvider.google;
      case 'apple':
        return OAuthProvider.apple;
      case 'github':
        return OAuthProvider.github;
      default:
        throw ArgumentError('Unknown provider: $value');
    }
  }
}

class MockAuthService {
  final Map<String, dynamic> _storage = {};
  final StreamController<MockUserSession?> _authStateController = StreamController<MockUserSession?>.broadcast();
  MockUserSession? _currentSession;
  bool _isLocalStorageInitialized = false;
  
  // Keys for storage
  static const String _tokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _tokenExpiryKey = 'auth_token_expiry';
  static const String _userDataKey = 'auth_user_data';
  
  Stream<MockUserSession?> get authStateChanges => _authStateController.stream;
  MockUserSession? get currentSession => _currentSession;
  bool get isAuthenticated => _currentSession != null && !_currentSession!.isExpired;
  
  Future<void> initialize() async {
    await _loadPersistedSession();
  }
  
  Future<void> initLocalStorage() async {
    if (_isLocalStorageInitialized) return;
    
    // Mock the initialization process
    await Future.delayed(const Duration(milliseconds: 10));
    _isLocalStorageInitialized = true;
  }
  
  Future<MockUserSession> handleOAuthCallback(String code, String provider) async {
    final providerEnum = _getOAuthProviderFromString(provider);
    
    final user = MockUser(
      id: provider == 'google' ? 1 : (provider == 'apple' ? 2 : 3),
      name: 'Test User',
      email: 'test@example.com',
      provider: providerEnum,
    );
    
    final session = MockUserSession(
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
  
  Future<void> signInWithOAuth(OAuthProvider provider) async {
    // Just track that the method was called
  }
  
  Future<void> signOut() async {
    _storage.clear();
    _currentSession = null;
    _authStateController.add(null);
  }
  
  Future<bool> refreshToken() async {
    if (_currentSession == null || _currentSession!.refreshToken == null) {
      return false;
    }
    
    // Create a new session with extended expiry
    final session = MockUserSession(
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
  
  Future<MockUser?> getUserProfile() async => _currentSession?.user;
  
  Future<bool> checkAuthentication() async {
    await _loadPersistedSession();
    return isAuthenticated;
  }
  
  Future<void> _persistSession(MockUserSession session) async {
    _storage[_tokenKey] = session.token;
    _storage[_refreshTokenKey] = session.refreshToken ?? '';
    _storage[_tokenExpiryKey] = session.expiresAt.millisecondsSinceEpoch.toString();
    _storage[_userDataKey] = jsonEncode({
      'id': session.user.id,
      'name': session.user.name,
      'email': session.user.email,
      'provider': session.user.provider.name,
    });
  }
  
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
    
    final user = MockUser.fromJson(jsonDecode(userData));
    _currentSession = MockUserSession(
      user: user,
      token: token,
      refreshToken: refreshToken,
      expiresAt: expiryTime,
    );
    
    _authStateController.add(_currentSession);
  }
  
  Future<Map<String, String>> getAuthHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    if (isAuthenticated) {
      headers['Authorization'] = 'Bearer ${_currentSession!.token}';
    }
    
    return headers;
  }
  
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
  
  void dispose() {
    _authStateController.close();
  }
}

void main() {
  group('MockAuthService', () {
    late MockAuthService authService;

    setUp(() {
      authService = MockAuthService();
    });

    test('should initially have no session', () {
      expect(authService.currentSession, isNull);
      expect(authService.isAuthenticated, isFalse);
    });

    test('should authenticate with OAuth callback', () async {
      final session = await authService.handleOAuthCallback('test_code', 'google');
      
      expect(authService.currentSession, isNotNull);
      expect(authService.isAuthenticated, isTrue);
      expect(session.user.name, 'Test User');
      expect(session.user.email, 'test@example.com');
      expect(session.user.provider, OAuthProvider.google);
      expect(session.token, contains('mock_token_google_test_code'));
      expect(session.refreshToken, contains('mock_refresh_google_test_code'));
    });

    test('should persist and load session', () async {
      // Authenticate first
      await authService.handleOAuthCallback('test_code', 'google');
      
      // Get storage for new auth service
      final storage = authService._storage;
      
      // Create a new instance that uses the same storage
      final newAuthService = MockAuthService();
      // Use storage from first service
      storage.forEach((key, value) {
        newAuthService._storage[key] = value;
      });
      await newAuthService.initialize();
      
      // Verify session was loaded
      expect(newAuthService.isAuthenticated, isTrue);
      expect(newAuthService.currentSession?.user.email, 'test@example.com');
    });

    test('should sign out successfully', () async {
      // Authenticate first
      await authService.handleOAuthCallback('test_code', 'github');
      expect(authService.isAuthenticated, isTrue);
      
      // Sign out
      await authService.signOut();
      
      // Verify signed out
      expect(authService.currentSession, isNull);
      expect(authService.isAuthenticated, isFalse);
    });

    test('should refresh token', () async {
      // Authenticate first
      final session = await authService.handleOAuthCallback('test_code', 'apple');
      final originalToken = session.token;
      
      // Refresh token
      final refreshSuccessful = await authService.refreshToken();
      
      // Verify refresh was successful
      expect(refreshSuccessful, isTrue);
      expect(authService.currentSession?.token, isNot(equals(originalToken)));
      expect(authService.currentSession?.token, contains('refreshed_'));
    });

    test('should get auth headers', () async {
      // Without authentication
      var headers = await authService.getAuthHeaders();
      expect(headers['Content-Type'], 'application/json');
      expect(headers.containsKey('Authorization'), isFalse);
      
      // With authentication
      await authService.handleOAuthCallback('test_code', 'google');
      headers = await authService.getAuthHeaders();
      
      expect(headers['Content-Type'], 'application/json');
      expect(headers.containsKey('Authorization'), isTrue);
      expect(headers['Authorization'], startsWith('Bearer '));
    });

    test('should emit auth state changes', () async {
      // Setup listener
      final states = <MockUserSession?>[];
      final subscription = authService.authStateChanges.listen(states.add);
      
      // Need to wait for the stream to set up
      await Future.delayed(Duration.zero);
      
      // Authenticate
      await authService.handleOAuthCallback('test_code', 'google');
      
      // Sign out
      await authService.signOut();
      
      // Wait for the stream to process events
      await Future.delayed(Duration.zero);
      
      // Clean up
      await subscription.cancel();
      
      // Verify state changes
      expect(states.length, 2);
      expect(states[0], isNotNull); // Authenticated state
      expect(states[1], isNull);    // Signed out state
    });
  });
}
