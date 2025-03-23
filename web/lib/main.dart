import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:link_shortener/config/app_config.dart';
import 'package:link_shortener/config/app_config_provider.dart';
import 'package:link_shortener/models/auth/user.dart';
import 'package:link_shortener/screens/home_screen.dart';
import 'package:link_shortener/screens/oauth_callback_screen.dart';
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
    
    // Check if this is an OAuth callback
    if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'auth') {
      if (uri.pathSegments.length >= 3 && uri.pathSegments[1] == 'callback') {
        // Get provider and code
        final provider = uri.pathSegments[2];
        final code = uri.queryParameters['code'] ?? '';
        
        if (kDebugMode) {
          print('Detected OAuth callback for provider: $provider');
        }
        
        // Clear the URL to avoid processing the callback again on refresh
        html.window.history.pushState({}, '', '/');
        
        // Handle callback after the app is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => OAuthCallbackScreen(
                code: code,
                provider: provider,
              ),
            ),
          );
        });
      }
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
          // Don't include '/' route since we're using 'home'
          '/auth/callback/google': (context) => const OAuthCallbackScreen(
            code: '',
            provider: 'google',
          ),
          '/auth/callback/github': (context) => const OAuthCallbackScreen(
            code: '',
            provider: 'github',
          ),
          '/auth/callback/apple': (context) => const OAuthCallbackScreen(
            code: '',
            provider: 'apple',
          ),
        },
        // We use home as the default route
        home: HomeScreen(
          authService: widget.authService,
          urlService: widget.urlService,
        ),
        // Handle dynamic routes for OAuth callbacks
        onGenerateRoute: (settings) {
          // Parse the route
          final uri = Uri.parse(settings.name ?? '/');
          
          // Check if this is an OAuth callback route
          if (uri.pathSegments.length >= 3 && 
              uri.pathSegments[0] == 'auth' && 
              uri.pathSegments[1] == 'callback') {
            
            final provider = uri.pathSegments[2];
            final code = uri.queryParameters['code'] ?? '';
            
            return MaterialPageRoute(
              builder: (context) => OAuthCallbackScreen(
                code: code,
                provider: provider,
              ),
            );
          }
          
          // Return null to let the MaterialApp handle the route
          return null;
        },
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
