import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:link_shortener/config/app_config.dart';
import 'package:link_shortener/models/auth/oauth_provider.dart';
import 'package:link_shortener/models/auth/user.dart';
import 'package:link_shortener/models/auth/user_session.dart';
import 'package:link_shortener/utils/notification_utils.dart';
import 'package:localstorage/localstorage.dart';
import 'package:universal_html/html.dart' as html;

class AuthResult {
  AuthResult({
    this.user,
    this.statusCode = 200,
    this.errorMessage,
  });

  final User? user;

  final int statusCode;

  final String? errorMessage;

  bool get isTokenInvalid => statusCode == 401;

  bool get isServerError => statusCode != 200 && statusCode != 401;

  bool get isSuccess => statusCode == 200;
}

class AuthService {
  factory AuthService() => _instance;
  AuthService._internal() {
    _storage = LocalStorage('link_shortener_auth');
  }

  static AuthService _instance = AuthService._internal();

  late final LocalStorage _storage;
  bool _isLocalStorageInitialized = false;

  @visibleForTesting
  static void resetForTesting() {
    _instance.dispose();
    _instance = AuthService._internal();
  }

  final StreamController<UserSession?> _authStateController =
      StreamController<UserSession?>.broadcast();
  Stream<UserSession?> get authStateChanges => _authStateController.stream;

  UserSession? _currentSession;
  UserSession? get currentSession => _currentSession;
  bool get isAuthenticated =>
      _currentSession != null && !_currentSession!.isExpired;

  final _config = AppConfig.fromWindow();
  final _client = http.Client();

  static const String _tokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _tokenExpiryKey = 'auth_token_expiry';
  static const String _userDataKey = 'auth_user_data';

  Future<void> initialize() async {
    await _loadPersistedSession();
  }

  Future<void> initLocalStorage() async {
    if (_isLocalStorageInitialized) return;

    await _storage.ready;

    _isLocalStorageInitialized = true;

    if (kDebugMode) {
      print('LocalStorage initialized');
    }
  }

  Future<void> saveSession(UserSession session) async {
    await initLocalStorage();

    await _persistSession(session);

    _currentSession = session;
    _authStateController.add(session);

    if (kDebugMode) {
      print('Session saved successfully');
      print('Token expires at: ${session.expiresAt}');
    }
  }

  Future<void> signInWithOAuth(OAuthProvider provider, {BuildContext? context}) async {
    String providerName;

    switch (provider) {
      case OAuthProvider.google:
        providerName = 'google';
        break;
      case OAuthProvider.apple:
        providerName = 'apple';
        break;
      case OAuthProvider.github:
        providerName = 'github';
        break;
      default:
        throw Exception('Unknown oauth2 provider');
    }

    final baseUrl = _config.apiBaseUrl;
    final url = '$baseUrl/api/auth/$providerName';

    if (!kIsWeb) {
      throw Exception("Other platforms then web aren't supported");
    }

    html.window.location.href = url;
  }

  Future<bool> refreshToken({BuildContext? context}) async {
    if (_currentSession == null || _currentSession!.refreshToken == '') {
      if (kDebugMode) {
        print('Unable refresh token: no accessToken or refreshToken');
      }

      NotificationUtils.showWarning(context, 'Authorization required, please Log In again');

      return false;
    }

    try {
      if (kDebugMode) {
        print('New attempt to refresh token');
        print('URL: ${_config.apiBaseUrl}/api/auth/refresh');
      }

      print('TOKEN: ${_currentSession!.refreshToken}');

      final response = await _client.post(
          Uri.parse('${_config.apiBaseUrl}/api/auth/refresh'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refresh_token': _currentSession!.refreshToken}));

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body.length > 1000 ? '${response.body.substring(0, 1000)}...' : response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final session = _createSessionFromResponse(data);

        if (kDebugMode) {
          print('Token updated');
          print('Expires at: ${session.expiresAt}');
        }

        await _persistSession(session);

        _currentSession = session;
        _authStateController.add(session);

        return true;
      } else {
        if (kDebugMode) {
          print('Error to refresh session: ${response.statusCode}');
        }

        NotificationUtils.showError(context, 'Session expired, please Log in again');

        await signOut();
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error to refresh session: $e');
      }

      NotificationUtils.showError(context, 'Error to refresh session');

      await signOut();
      return false;
    }
  }

  Future<void> signOut({BuildContext? context}) async {
    if (isAuthenticated) {
      try {
        await _client
            .post(
            Uri.parse('${_config.apiBaseUrl}/api/auth/logout'),
            headers: await getAuthHeaders(context: context),
        );
      } catch (e) {
        if (kDebugMode) {
          print('Error during logout: $e');
        }
      }
    }

    await initLocalStorage();
    await _storage.deleteItem(_tokenKey);
    await _storage.deleteItem(_refreshTokenKey);
    await _storage.deleteItem(_tokenExpiryKey);
    await _storage.deleteItem(_userDataKey);

    _currentSession = null;
    _authStateController.add(null);
  }

  Future<AuthResult> getUserProfileWithAuthStatus({BuildContext? context}) async {
    if (!isAuthenticated) {
      if (kDebugMode) {
        print('Невозможно получить профиль: пользователь не авторизован');
      }

      return AuthResult(
        statusCode: 401,
        errorMessage: 'User not authenticated'
      );
    }

    try {
      if (kDebugMode) {
        print('Запрос профиля пользователя: ${_config.apiBaseUrl}/api/auth/me');
      }

      final response = await _client
          .get(Uri.parse(
          '${_config.apiBaseUrl}/api/auth/me'),
          headers: await getAuthHeaders(context: context),
      );

      if (kDebugMode) {
        print('Статус ответа: ${response.statusCode}');
        print('Тело ответа: ${response.body}');
      }

      if (response.statusCode == 401) {
        if (kDebugMode) {
          print('Токен недействителен или просрочен (401)');
        }

        return AuthResult(
          statusCode: 401,
          errorMessage: 'Invalid or expired token',
        );
      } else if (response.statusCode != 200) {
        if (kDebugMode) {
          print('Неуспешный статус ответа: ${response.statusCode}');
        }

        return AuthResult(
          statusCode: response.statusCode,
          errorMessage: 'Server error: ${response.body}',
        );
      }

      if (response.body.isEmpty) {
        if (kDebugMode) {
          print('Ответ пустой');
        }

        return AuthResult(
          errorMessage: 'Empty response',
        );
      }

      try {
        final data = jsonDecode(response.body);

        if (kDebugMode) {
          print('Данные: $data');
        }

        if (data == null) {
          if (kDebugMode) {
            print('Разобранные данные null');
          }

          return AuthResult(
            errorMessage: 'Null data',
          );
        }

        if (data is Map<String, dynamic>) {
          if (kDebugMode) {
            print('Найдены данные пользователя в корне объекта');
          }

          final user = User.fromJson(data);
          return AuthResult(user: user);
        }

        if (kDebugMode) {
          print('Формат данных не соответствует ожидаемому: $data');
        }

        return AuthResult(
          errorMessage: 'Invalid data format',
        );
      } catch (parseError) {
        if (kDebugMode) {
          print('Ошибка при разборе JSON: $parseError');
        }

        return AuthResult(
          errorMessage: 'JSON parse error: $parseError',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user profile: $e');
      }

      return AuthResult(
        statusCode: 500,
        errorMessage: 'Connection error: $e',
      );
    }
  }

  bool _isTokenExpiredOrCloseToExpiry() {
    if (_currentSession == null) return true;

    final now = DateTime.now();
    const expiryBuffer = Duration(minutes: 5);

    return now.isAfter(_currentSession!.expiresAt.subtract(expiryBuffer));
  }

  UserSession _createSessionFromResponse(Map<String, dynamic> data) {
    final user = data.containsKey('user') ? User.fromJson(data['user']) : null;
    final token = data['access_token'] as String;
    final refreshToken = data['refresh_token'] as String;

    if (!data.containsKey('access_token_expiry_ms') || data['access_token_expiry_ms'] == null) {
      throw Exception('Invalid session object: access_token_expiry_ms is invalid');
    }

    final expiryMs = data['access_token_expiry_ms'] as int;
    final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiryMs);

    if (kDebugMode) {
      print('Использую срок действия токена из access_token_expiry_ms: $expiryTime');
    }

    return UserSession(
      user: user,
      token: token,
      refreshToken: refreshToken,
      expiresAt: expiryTime,
    );
  }

  Future<void> _loadPersistedSession() async {
    if (kDebugMode) {
      print('Loading saved session...');
    }

    await initLocalStorage();

    final token = _storage.getItem(_tokenKey);
    final refreshToken = _storage.getItem(_refreshTokenKey);
    final expiryTimeMsString = _storage.getItem(_tokenExpiryKey);
    final userData = _storage.getItem(_userDataKey);

    final expiryTimeMs =
        expiryTimeMsString != null ? int.parse(expiryTimeMsString) : null;

    if (kDebugMode) {
      print('Got from local storage:');
      print(
          '- token: ${token != null ? '${token.substring(0, 10)}...' : 'null'}');
      print(
          '- refreshToken: ${refreshToken != null ? '${refreshToken.substring(0, 10)}...' : 'null'}');
      print('- expiryTimeMs: $expiryTimeMs');
      print('- userData: ${userData != null ? 'exists' : 'null'}');
    }

    if (token == null ||
        refreshToken == null ||
        expiryTimeMs == null ||
        userData == null) {
      if (kDebugMode) {
        print('Session is corrupted');
      }

      return;
    }

    final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiryTimeMs);

    if (kDebugMode) {
      print('Access Token expires at: $expiryTime');
      print('Current time: ${DateTime.now()}');
      print(
          'Token ${DateTime.now().isAfter(expiryTime) ? 'expired' : 'valid'}');
    }

    if (DateTime.now().isAfter(expiryTime)) {
      final tempUser = User.fromJson(jsonDecode(userData));
      _currentSession = UserSession(
        user: tempUser,
        token: token,
        refreshToken: refreshToken,
        expiresAt: expiryTime,
      );

      if (kDebugMode) {
        print('Token is expired, refreshing...');
      }

      final refreshed = await this.refreshToken();
      if (!refreshed) {
        _currentSession = null;
        if (kDebugMode) {
          print('Failed to refresh');
        }
        return;
      }

      if (kDebugMode) {
        print('Token refreshed');
      }

      return;
    }

    final user = User.fromJson(jsonDecode(userData));
    _currentSession = UserSession(
      user: user,
      token: token,
      refreshToken: refreshToken,
      expiresAt: expiryTime,
    );

    if (kDebugMode) {
      print('Session is restored, user: ${user.name}');
    }

    _authStateController.add(_currentSession);
  }

  Future<void> _persistSession(UserSession session) async {
    await initLocalStorage();

    await _storage.setItem(_tokenKey, session.token);
    await _storage.setItem(_refreshTokenKey, session.refreshToken);
    await _storage.setItem(
        _tokenExpiryKey, session.expiresAt.millisecondsSinceEpoch.toString());

    if (session.user != null) {
      await _storage.setItem(_userDataKey, jsonEncode(session.user!.toJson()));
    }

    if (kDebugMode) {
      print('Session persisted to localStorage');
      print('Token expires at: ${session.expiresAt}');
    }
  }

  Future<Map<String, String>> getAuthHeaders({BuildContext? context}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (isAuthenticated) {
      if (_isTokenExpiredOrCloseToExpiry()) {
        await refreshToken(context: context);
      }

      if (isAuthenticated) {
        headers['Authorization'] = 'Bearer ${_currentSession!.token}';
      }
    }

    return headers;
  }

  void dispose() {
    _authStateController.close();
    _client.close();

    if (_isLocalStorageInitialized) {
      _storage.dispose();
    }
  }

  Future<User?> getUserProfile() async {
    final result = await getUserProfileWithAuthStatus();
    return result.user;
  }

  Future<Map<String, dynamic>> handleOAuthSuccessCallback(Uri uri) async {
    final accessToken = uri.queryParameters['access_token'] ?? '';
    final refreshToken = uri.queryParameters['refresh_token'] ?? '';
    final expiresAtMS = int.tryParse(uri.queryParameters['expires_at_ms'] ?? '0') ?? 0;

    if (accessToken.isEmpty) {
      if (kDebugMode) {
        print("Token doesn't exist");
      }

      return {'success': false, 'error': "Token doesn't exist"};
    }

    if (kDebugMode) {
      print('Process OAuth callback:');
      print('accessToken: ${accessToken.isNotEmpty ? '${accessToken.substring(0, 10)}...' : 'empty'}');
      print('refreshToken: ${refreshToken.isNotEmpty ? '${refreshToken.substring(0, 10)}...' : 'empty'}');
      print('expiresAtMS: $expiresAtMS');
    }

    try {
      final tempSession = UserSession(
        token: accessToken,
        refreshToken: refreshToken,
        expiresAt: DateTime.fromMillisecondsSinceEpoch(expiresAtMS),
      );

      await saveSession(tempSession);

      return await _fetchUserProfileWithRetry(accessToken, refreshToken, expiresAtMS);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to handle OAuth callback: $e');
      }

      return {'success': false, 'error': 'Authorization issue: $e'};
    }
  }

  Future<Map<String, dynamic>> _fetchUserProfileWithRetry(
      String accessToken, String refreshToken, int expiresAtMS) async {
    const maxAttempts = 3;
    const retryDelay = Duration(milliseconds: 500);
    
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final authResult = await getUserProfileWithAuthStatus();

        if (authResult.isTokenInvalid) {
          await signOut();
          return {'success': false, 'error': 'Token is invalid'};
        }
        
        if (authResult.user != null) {
          if (kDebugMode) {
            print('Got user information : ${authResult.user!.name} (${authResult.user!.email})');
          }

          final completeSession = UserSession(
            token: accessToken,
            refreshToken: refreshToken,
            expiresAt: DateTime.fromMillisecondsSinceEpoch(expiresAtMS),
            user: authResult.user,
          );
          
          await saveSession(completeSession);

          return {'success': true};
        }
        
        if (authResult.isServerError && attempt < maxAttempts) {
          await Future.delayed(retryDelay);

          continue;
        }

        if (attempt >= maxAttempts) {
          await signOut();

          return {
            'success': false, 
            'error': 'Server error: ${authResult.statusCode} - ${authResult.errorMessage ?? "unknown error"}'
          };
        }
      } catch (e) {
        if (attempt >= maxAttempts) {
          await signOut();

          return {'success': false, 'error': 'Failed to get user information: $e'};
        }

        await Future.delayed(retryDelay);
      }
    }
    
    await signOut();

    return {'success': false, 'error': 'Failed to get user information'};
  }
}
