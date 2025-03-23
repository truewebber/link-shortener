import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:link_shortener/config/app_config.dart';
import 'package:link_shortener/config/app_config_provider.dart';
import 'package:link_shortener/models/auth/user_session.dart';
import 'package:link_shortener/screens/auth_fail_screen.dart';
import 'package:link_shortener/screens/auth_success_screen.dart';
import 'package:link_shortener/screens/home_screen.dart';
import 'package:link_shortener/services/auth_service.dart';
import 'package:link_shortener/services/url_service.dart';
import 'package:universal_html/html.dart' as html;

/// The entry point of the application
void main() {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  final config = _loadConfiguration();
  
  // Set up error logging for debug mode
  if (kDebugMode) {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
    };
    
    print('Starting Link Shortener App...');
    print('API Base URL: ${config.apiBaseUrl}');
    print('Environment: ${config.environment}');
  }
  
  // Initialize services
  final authService = AuthService()
  
  // Initialize authentication (load persisted sessions)
  ..initialize();
  
  // URL Service
  final urlService = UrlService();
  
  // Run the app
  runApp(LinkShortenerApp(
    config: config,
    authService: authService,
    urlService: urlService,
  ));
}

/// Loads the application configuration
AppConfig _loadConfiguration() {
  // Load configuration from window.APP_CONFIG if available (in web)
  // or from environment variables (in mobile/desktop)
  final config = AppConfig.fromWindow();
  
  // Debug logging - only in non-production
  if (kDebugMode) {
    print('Configuration loaded:');
    print('API Base URL: ${config.apiBaseUrl}');
    print('Environment: ${config.environment}');
  }
  
  return config;
}

/// The main application widget
class LinkShortenerApp extends StatefulWidget {
  /// Creates a new instance of the app
  const LinkShortenerApp({
    super.key,
    required this.config,
    required this.authService,
    required this.urlService,
  });
  
  /// The application configuration
  final AppConfig config;
  
  /// The authentication service
  final AuthService authService;
  
  /// The URL service
  final UrlService urlService;

  @override
  State<LinkShortenerApp> createState() => _LinkShortenerAppState();
}

class _LinkShortenerAppState extends State<LinkShortenerApp> {
  UserSession? _userSession;
  StreamSubscription? _authSubscription;
  
  @override
  void initState() {
    super.initState();
    
    // Listen for authentication state changes
    _authSubscription = widget.authService.authStateChanges.listen((session) {
      setState(() {
        _userSession = session;
      });
    });
    
    // Check if this is an OAuth callback
    if (kIsWeb) {
      _handlePotentialOAuthCallback();
    }
  }
  
  @override
  void dispose() {
    // Cancel the subscription when the widget is disposed
    _authSubscription?.cancel();
    super.dispose();
  }
  
  void _handlePotentialOAuthCallback() {
    // Get current URL
    final uri = Uri.parse(html.window.location.href);
    
    // Check if this is an OAuth success callback with tokens
    if (uri.pathSegments.length >= 3 && 
        uri.pathSegments[0] == 'app' && 
        uri.pathSegments[1] == 'auth') {
      
      final authResult = uri.pathSegments[2];
      
      if (kDebugMode) {
        print('Detected auth result: $authResult');
      }
      
      // Не меняем URL, потому что это уже обрабатывается через routes
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('Building LinkShortenerApp. Authenticated: ${_userSession != null}');
    }
    
    return AppConfigProvider(
      config: widget.config,
      child: MaterialApp(
        title: 'Link Shortener',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xff6750a4),
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xff6750a4),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        routes: {
          // Обработка успешной аутентификации
          '/app/auth/success': (context) {
            final uri = Uri.parse(html.window.location.href);
            final accessToken = uri.queryParameters['access_token'] ?? '';
            final refreshToken = uri.queryParameters['refresh_token'] ?? '';
            final expiresAt = int.tryParse(uri.queryParameters['expires_at'] ?? '0') ?? 0;
            
            // Очищаем URL
            html.window.history.pushState({}, '', '/');
            
            return AuthSuccessScreen(
              accessToken: accessToken,
              refreshToken: refreshToken,
              expiresAt: expiresAt,
            );
          },
          // Обработка ошибки аутентификации
          '/app/auth/fail': (context) {
            final uri = Uri.parse(html.window.location.href);
            final error = uri.queryParameters['error'] ?? 'Unknown error';
            
            // Очищаем URL
            html.window.history.pushState({}, '', '/');
            
            return AuthFailScreen(error: error);
          },
        },
        // We use home as the default route
        home: HomeScreen(
          authService: widget.authService,
          urlService: widget.urlService,
        ),
        // Handle dynamic routes for OAuth callbacks
        onGenerateRoute: (settings) => null,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties..add(DiagnosticsProperty<AppConfig>('config', widget.config))
    ..add(DiagnosticsProperty<UserSession?>('userSession', _userSession));
  }
}
