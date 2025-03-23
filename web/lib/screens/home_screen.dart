import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:link_shortener/models/auth/user.dart';
import 'package:link_shortener/screens/auth_screen.dart';
import 'package:link_shortener/screens/profile_screen.dart';
import 'package:link_shortener/services/auth_service.dart';
import 'package:link_shortener/services/url_service.dart';
import 'package:link_shortener/widgets/auth/user_profile_header.dart';
import 'package:link_shortener/widgets/feature_section.dart';
import 'package:link_shortener/widgets/url_shortener_form.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.authService,
    this.urlService,
  });

  final AuthService? authService;
  final UrlService? urlService;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AuthService _authService;
  late final UrlService _urlService;
  UserSession? _userSession;
  late StreamSubscription<UserSession?> _authSubscription;
  
  @override
  void initState() {
    super.initState();
    
    // Use the provided auth service or get the singleton instance
    _authService = widget.authService ?? AuthService();
    // Use the provided url service or get the singleton instance
    _urlService = widget.urlService ?? UrlService();
    
    // Initialize session state
    _userSession = _authService.currentSession;
    
    // Listen for auth state changes
    _authSubscription = _authService.authStateChanges.listen((session) {
      if (mounted) {
        setState(() {
          _userSession = session;
        });
      }
    });
    
    // Initialize authentication service
    _authService.initialize().then((_) {
      if (kDebugMode) {
        if (_authService.currentSession != null) {
          print('Авторизация успешна:');
          print('Пользователь: ${_authService.currentSession!.user.name} (${_authService.currentSession!.user.email})');
          print('Срок действия токена: ${_authService.currentSession!.expiresAt}');
        } else {
          print('Пользователь не авторизован');
        }
      }
    });
  }

  @override
  void dispose() {
    // Отписываемся от потока аутентификации
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('Building HomeScreen. Authenticated: ${_userSession != null}');
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Link Shortener'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          // Show different UI based on authentication state
          if (_userSession != null)
            UserProfileHeader(
              userSession: _userSession!,
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton(
                onPressed: _navigateToAuth,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Sign In'),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Different UI based on authentication
                  if (_userSession != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: _buildAuthenticatedBanner(context),
                    ),
                  
                  UrlShortenerForm(
                    // Pass user session to show different options for authenticated users
                    isAuthenticated: _userSession != null,
                    urlService: _urlService,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 64),
            const FeatureSection(),
            const SizedBox(height: 64),
          ],
        ),
      ),
      bottomNavigationBar: _buildRobustFooter(context),
    );
  }
  
  Widget _buildAuthenticatedBanner(BuildContext context) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withAlpha(77),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withAlpha(51),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified_user,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, ${_userSession!.user.name}!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'You now have access to additional features including custom expiration times and link management.',
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
            child: const Text('Profile'),
          ),
        ],
      ),
    );
  
  Widget _buildHeroSection(BuildContext context) => Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withAlpha(204),
          ],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive layout based on available width
          final isDesktop = constraints.maxWidth > 900;
          final isTablet = constraints.maxWidth > 600;
          
          return Column(
            children: [
              Text(
                'Shorten Your Links',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: isDesktop ? 600 : (isTablet ? 450 : double.infinity),
                child: Text(
                  _userSession != null
                      ? 'Create short, memorable links with full control over expiration and tracking features.'
                      : 'Create short, memorable links that redirect to your long URLs. Share them easily on social media, emails, or messages.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withAlpha(230),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (_userSession == null) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _navigateToAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Sign In for More Features'),
                ),
              ],
            ],
          );
        },
      ),
    );
  
  Widget _buildRobustFooter(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      color: Colors.grey.shade200,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            children: [
              TextButton(
                onPressed: () {},
                child: const Text('Terms of Service'),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Privacy Policy'),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Contact Us'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '© ${DateTime.now().year} Link Shortener. All rights reserved.',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  
  /// Navigate to the auth screen
  void _navigateToAuth() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }
}
