import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:link_shortener/config/app_config.dart';
import 'package:link_shortener/config/app_config_provider.dart';
import 'package:link_shortener/models/auth/user_session.dart';
import 'package:link_shortener/screens/auth_screen.dart';
import 'package:link_shortener/screens/home_screen.dart';
import 'package:link_shortener/screens/legal/contact_us.dart';
import 'package:link_shortener/screens/legal/privacy_policy.dart';
import 'package:link_shortener/screens/legal/terms_of_service.dart';
import 'package:link_shortener/screens/profile_screen.dart';
import 'package:link_shortener/screens/url_management_screen.dart';
import 'package:link_shortener/services/auth_service.dart';
import 'package:link_shortener/services/url_service.dart';
import 'package:link_shortener/utils/notification_utils.dart';
import 'package:link_shortener/widgets/auth/user_profile_header.dart';
import 'package:link_shortener/widgets/common/footer.dart';
import 'package:universal_html/html.dart' as html;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromWindow();

  if (kDebugMode) {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
    };

    print('Starting Link Shortener App...');
    print('API Base URL: ${config.apiBaseUrl}');
    print('Google Captcha site key: ${config.googleCaptchaSiteKey}');
    print('Environment: ${config.environment}');
  }

  final authService = AuthService()..initialize();

  final urlService = UrlService();

  runApp(LinkShortenerApp(
    config: config,
    authService: authService,
    urlService: urlService,
  ));
}

class LinkShortenerApp extends StatefulWidget {
  const LinkShortenerApp({
    super.key,
    required this.config,
    required this.authService,
    required this.urlService,
  });

  final AppConfig config;

  final AuthService authService;

  final UrlService urlService;

  @override
  State<LinkShortenerApp> createState() => _LinkShortenerAppState();
}

class _LinkShortenerAppState extends State<LinkShortenerApp> {
  UserSession? _userSession;
  StreamSubscription? _authSubscription;
  bool _isHandlingOAuth = false;

  @override
  void initState() {
    super.initState();

    _authSubscription = widget.authService.authStateChanges.listen((session) {
      setState(() {
        _userSession = session;
      });
    });

    if (kIsWeb) {
      _handlePotentialOAuthCallback();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _handlePotentialOAuthCallback() {
    final uri = Uri.parse(html.window.location.href);

    if (kDebugMode) {
      print('_handlePotentialOAuthCallback: ${uri.path}');
    }

    if (_isHandlingOAuth) {
      if (kDebugMode) {
        print('OAuth callback handling already in progress, skipping');
      }
      return;
    }

    switch (uri.path) {
      case '/app/auth/success':
        _isHandlingOAuth = true;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          try {
            final result =
                await widget.authService.handleOAuthSuccessCallback(uri);

            if (kDebugMode) {
              print('OAuth callback result: ${result['success']}');
              print('Error message: ${result['error']}');
            }

            if (result['success']) {
              NotificationUtils.showSuccess(
                  navigatorKey.currentContext, 'Authorization successful');
            } else {
              NotificationUtils.showError(
                  navigatorKey.currentContext, 'Failed to authorize');
            }
          } catch (e) {
            if (kDebugMode) {
              print('Error handling OAuth callback: $e');
            }
          } finally {
            html.window.history.pushState({}, '', '/');
            _isHandlingOAuth = false;
          }
        });
        break;
      case '/app/auth/fail':
        _isHandlingOAuth = true;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          try {
            if (kDebugMode) {
              print('OAuth callback result: failed');
              print('Error message: ${uri.queryParameters['error']}');
            }

            NotificationUtils.showError(
                navigatorKey.currentContext, 'Failed to authorize');
          } catch (e) {
            if (kDebugMode) {
              print('Error handling OAuth failure: $e');
            }
          } finally {
            html.window.history.pushState({}, '', '/');
            _isHandlingOAuth = false;
          }
        });
        break;
      default:
        if (kDebugMode) {
          print('SKIP _handlePotentialOAuthCallback: ${uri.path}');
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print(
          'Building LinkShortenerApp. Authenticated: ${_userSession != null}');
    }

    return AppConfigProvider(
      config: widget.config,
      child: MaterialApp(
        title: 'Link Shortener',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
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
        home: MainScreen(
          body: HomeScreen(
            authService: widget.authService,
            urlService: widget.urlService,
          ),
          authService: widget.authService,
        ),
        routes: {
          '/urls': (context) => MainScreen(
                body: const UrlManagementScreen(),
                authService: widget.authService,
              ),
          '/profile': (context) => MainScreen(
                body: const ProfileScreen(),
                authService: widget.authService,
              ),
          '/auth': (context) => MainScreen(
                body: const AuthScreen(),
                authService: widget.authService,
              ),
          '/terms': (context) => MainScreen(
                body: const TermsOfServiceScreen(),
                authService: widget.authService,
              ),
          '/privacy': (context) => MainScreen(
                body: const PrivacyPolicyScreen(),
                authService: widget.authService,
              ),
          '/contact': (context) => MainScreen(
                body: const ContactUsScreen(),
                authService: widget.authService,
              ),
        },
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<AppConfig>('config', widget.config))
      ..add(DiagnosticsProperty<UserSession?>('userSession', _userSession));
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({
    super.key,
    required this.body,
    required this.authService,
  });

  final Widget body;
  final AuthService authService;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Link Shortener'),
          actions: [
            if (authService.currentSession != null && body is! ProfileScreen)
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: UserProfileHeader(
                  userSession: authService.currentSession!,
                  authService: authService,
                  onSignOutSuccess: () {
                    NotificationUtils.showSuccess(
                      context,
                      'Successfully signed out',
                    );
                  },
                  onSignOutError: (error) {
                    NotificationUtils.showError(
                      context,
                      'Failed to sign out: $error',
                    );
                  },
                ),
              )
            else if (authService.currentSession == null && body is! AuthScreen)
              TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/auth'),
                icon: const Icon(Icons.login),
                label: const Text('Sign In'),
              ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  body,
                  const Footer(),
                ],
              ),
            ),
          ),
        ),
      );
}
