import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:link_shortener/config/app_config.dart';
import 'package:link_shortener/models/auth/oauth_provider.dart';
import 'package:link_shortener/models/auth/user.dart';
import 'package:link_shortener/models/auth/user_session.dart';
import 'package:localstorage/localstorage.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

/// Service for handling user authentication
class AuthService {
  factory AuthService() => _instance;
  AuthService._internal() {
    _storage = LocalStorage('link_shortener_auth');
  }

  // Singleton instance
  static AuthService _instance = AuthService._internal();

  // LocalStorage instance
  late final LocalStorage _storage;
  bool _isLocalStorageInitialized = false;

  // ДОБАВИТЬ: Метод для тестирования, который позволяет переопределить LocalStorage
  @visibleForTesting
  static void resetForTesting() {
    // Очищаем ресурсы старого экземпляра
    _instance.dispose();
    // Создаем новый экземпляр с чистым LocalStorage для тестов
    _instance = AuthService._internal();
  }

  // Authentication state controller
  final StreamController<UserSession?> _authStateController =
      StreamController<UserSession?>.broadcast();
  Stream<UserSession?> get authStateChanges => _authStateController.stream;

  // Current user session
  UserSession? _currentSession;
  UserSession? get currentSession => _currentSession;
  bool get isAuthenticated =>
      _currentSession != null && !_currentSession!.isExpired;

  final _config = AppConfig.fromWindow();
  final _client = http.Client();

  // Storage keys
  static const String _tokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _tokenExpiryKey = 'auth_token_expiry';
  static const String _userDataKey = 'auth_user_data';

  // Initialize the service
  Future<void> initialize() async {
    await _loadPersistedSession();
  }

  // Initialize localStorage
  Future<void> initLocalStorage() async {
    if (_isLocalStorageInitialized) return;

    await _storage.ready;

    _isLocalStorageInitialized = true;

    if (kDebugMode) {
      print('LocalStorage initialized');
    }
  }

  // Save user session
  Future<void> saveSession(UserSession session) async {
    await initLocalStorage();
    
    // Save to storage
    await _persistSession(session);
    
    // Update current session
    _currentSession = session;
    _authStateController.add(session);
    
    if (kDebugMode) {
      print('Session saved successfully');
      print('Token expires at: ${session.expiresAt}');
    }
  }

  // Start OAuth flow for a provider
  Future<void> signInWithOAuth(OAuthProvider provider) async {
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
    }

    // Create the OAuth URL
    final baseUrl = _config.apiBaseUrl;
    final url = '$baseUrl/api/auth/$providerName';

    if (kIsWeb) {
      // Для веб просто перенаправляем на страницу OAuth
      html.window.location.href = url;
    } else {
      // Для мобильных устройств используем url_launcher
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch $url');
      }
    }
  }

  // Refresh the token
  Future<bool> refreshToken() async {
    if (_currentSession == null || _currentSession!.refreshToken == '') {
      if (kDebugMode) {
        print(
            '⚠️ Невозможно обновить токен: нет текущей сессии или refreshToken');
      }
      return false;
    }

    try {
      if (kDebugMode) {
        print('🔄 Попытка обновления токена...');
        print('URL: ${_config.apiBaseUrl}/api/auth/refresh');
      }

      final response = await _client.post(
          Uri.parse('${_config.apiBaseUrl}/api/auth/refresh'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refresh_token': _currentSession!.refreshToken}));

      if (kDebugMode) {
        print('Статус ответа: ${response.statusCode}');
        print(
            'Тело ответа: ${response.body.length > 1000 ? '${response.body.substring(0, 1000)}...' : response.body}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final session = _createSessionFromResponse(data);

        if (kDebugMode) {
          print('✅ Токен успешно обновлен');
          print('Новый срок действия: ${session.expiresAt}');
        }

        // Save session data
        await _persistSession(session);

        // Update current session
        _currentSession = session;
        _authStateController.add(session);

        return true;
      } else {
        if (kDebugMode) {
          print('❌ Не удалось обновить токен: ${response.statusCode}');
        }
        // If refresh fails, sign out
        await signOut();
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Ошибка при обновлении токена: $e');
      }
      // If refresh fails, sign out
      await signOut();
      return false;
    }
  }

  // Method to sign out
  Future<void> signOut() async {
    if (isAuthenticated) {
      try {
        // Call the logout endpoint if authenticated
        await _client
            .post(Uri.parse('${_config.apiBaseUrl}/api/auth/logout'), headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${_currentSession!.token}'
        });
      } catch (e) {
        if (kDebugMode) {
          print('Error during logout: $e');
        }
      }
    }

    // Clear stored tokens
    await initLocalStorage();
    await _storage.deleteItem(_tokenKey);
    await _storage.deleteItem(_refreshTokenKey);
    await _storage.deleteItem(_tokenExpiryKey);
    await _storage.deleteItem(_userDataKey);

    // Update state
    _currentSession = null;
    _authStateController.add(null);
  }

  // Get user profile
  Future<User?> getUserProfile() async {
    if (!isAuthenticated) {
      return null;
    }

    try {
      final response = await _client
          .get(Uri.parse('${_config.apiBaseUrl}/api/auth/me'), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_currentSession!.token}'
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['user']);
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user profile: $e');
      }
      return null;
    }
  }

  // Check if token is expired or about to expire
  bool _isTokenExpiredOrCloseToExpiry() {
    if (_currentSession == null) return true;

    final now = DateTime.now();
    const expiryBuffer = Duration(minutes: 5);
    return now.isAfter(_currentSession!.expiresAt.subtract(expiryBuffer));
  }

  // Create session from API response
  UserSession _createSessionFromResponse(Map<String, dynamic> data) {
    final user = data.containsKey('user') ? User.fromJson(data['user']) : null;
    final token = data['access_token'] as String;
    final refreshToken = data['refresh_token'] as String;

    // Calculate expiry time from server data or default to 1 hour
    DateTime expiryTime;
    if (data.containsKey('access_token_expiry_ms') && data['access_token_expiry_ms'] != null) {
      try {
        final expiryMs = data['access_token_expiry_ms'] as int;
        expiryTime = DateTime.fromMillisecondsSinceEpoch(expiryMs);
        if (kDebugMode) {
          print('Использую срок действия токена из access_token_expiry_ms: $expiryTime');
        }
      } catch (e) {
        expiryTime = DateTime.now().add(const Duration(hours: 1));
        if (kDebugMode) {
          print('Не удалось использовать access_token_expiry_ms: $e');
          print('Использую срок действия по умолчанию: $expiryTime');
        }
      }
    } else if (data.containsKey('expires_at') && data['expires_at'] != null) {
      try {
        // Check if expires_at is a string (ISO format) or timestamp in seconds
        final expiresAt = data['expires_at'];
        if (expiresAt is String) {
          expiryTime = DateTime.parse(expiresAt);
        } else if (expiresAt is int) {
          expiryTime = DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
        } else {
          throw Exception('Unexpected expires_at format: $expiresAt');
        }
        
        if (kDebugMode) {
          print('Использую срок действия токена из expires_at: $expiryTime');
        }
      } catch (e) {
        expiryTime = DateTime.now().add(const Duration(hours: 1));
        if (kDebugMode) {
          print('Не удалось распарсить срок действия токена из expires_at: $e');
          print('Использую срок действия по умолчанию: $expiryTime');
        }
      }
    } else {
      // Default expiry time (1 hour from now)
      expiryTime = DateTime.now().add(const Duration(hours: 1));
      if (kDebugMode) {
        print('Сервер не предоставил срок действия токена');
        print('Использую срок действия по умолчанию: $expiryTime');
      }
    }

    return UserSession(
      user: user,
      token: token,
      refreshToken: refreshToken,
      expiresAt: expiryTime,
    );
  }

  // Load persisted session from storage
  Future<void> _loadPersistedSession() async {
    if (kDebugMode) {
      print('Загрузка сохраненной сессии...');
    }

    await initLocalStorage();

    final token = _storage.getItem(_tokenKey);
    final refreshToken = _storage.getItem(_refreshTokenKey);
    final expiryTimeMsString = _storage.getItem(_tokenExpiryKey);
    final userData = _storage.getItem(_userDataKey);

    final expiryTimeMs =
        expiryTimeMsString != null ? int.parse(expiryTimeMsString) : null;

    if (kDebugMode) {
      print('Данные из localStorage:');
      print(
          '- token: ${token != null ? '${token.substring(0, 10)}...' : 'null'}');
      print(
          '- refreshToken: ${refreshToken != null ? '${refreshToken.substring(0, 10)}...' : 'null'}');
      print('- expiryTimeMs: $expiryTimeMs');
      print('- userData: ${userData != null ? 'данные есть' : 'null'}');
    }

    if (token == null ||
        refreshToken == null ||
        expiryTimeMs == null ||
        userData == null) {
      if (kDebugMode) {
        print('⚠️ Отсутствуют необходимые данные для восстановления сессии');
      }
      return;
    }

    final expiryTime = DateTime.fromMillisecondsSinceEpoch(expiryTimeMs);

    if (kDebugMode) {
      print('Срок действия токена: $expiryTime');
      print('Текущее время: ${DateTime.now()}');
      print(
          'Токен ${DateTime.now().isAfter(expiryTime) ? 'просрочен' : 'действителен'}');
    }

    // If token is expired, try to refresh
    if (DateTime.now().isAfter(expiryTime)) {
      // Set a temporary session so we can refresh the token
      final tempUser = User.fromJson(jsonDecode(userData));
      _currentSession = UserSession(
        user: tempUser,
        token: token,
        refreshToken: refreshToken,
        expiresAt: expiryTime,
      );

      if (kDebugMode) {
        print('⚠️ Токен просрочен, пытаемся обновить...');
      }

      // Try to refresh the token
      final refreshed = await this.refreshToken();
      if (!refreshed) {
        // If refresh failed, clear session
        _currentSession = null;
        if (kDebugMode) {
          print('❌ Не удалось обновить токен');
        }
        return;
      }

      if (kDebugMode) {
        print('✅ Токен успешно обновлен');
      }
    } else {
      // Token is still valid
      final user = User.fromJson(jsonDecode(userData));
      _currentSession = UserSession(
        user: user,
        token: token,
        refreshToken: refreshToken,
        expiresAt: expiryTime,
      );

      if (kDebugMode) {
        print('✅ Сессия восстановлена. Пользователь: ${user.name}');
      }

      // Notify listeners
      _authStateController.add(_currentSession);
    }
  }

  // Persist session to storage
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

  // Add auth token to request headers
  Future<Map<String, String>> getAuthHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (isAuthenticated) {
      // Check if token is expired or about to expire
      if (_isTokenExpiredOrCloseToExpiry()) {
        // Try to refresh the token
        await refreshToken();
      }

      // Add token if we're authenticated
      if (isAuthenticated) {
        headers['Authorization'] = 'Bearer ${_currentSession!.token}';
      }
    }

    return headers;
  }

  // Dispose method to clean up resources
  void dispose() {
    _authStateController.close();
    _client.close();
    
    // Очистить таймеры, связанные с LocalStorage
    if (_isLocalStorageInitialized) {
      // Попытка явного освобождения ресурсов LocalStorage
      _storage.dispose();
    }
  }

  // Force check authentication status
  Future<bool> checkAuthentication() async {
    if (kDebugMode) {
      print('Принудительная проверка авторизации...');
    }

    await _loadPersistedSession();

    if (kDebugMode) {
      print(
          'Статус авторизации после проверки: ${isAuthenticated ? "авторизован" : "не авторизован"}');
      if (isAuthenticated) {
        print('Пользователь: ${currentSession!.user?.name ?? "неизвестно"}');
        print('Email: ${currentSession!.user?.email ?? "неизвестно"}');
        print('Срок действия: ${currentSession!.expiresAt}');
      }
    }

    return isAuthenticated;
  }
}
