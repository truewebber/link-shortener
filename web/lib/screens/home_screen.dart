import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:link_shortener/models/auth/user.dart';
import 'package:link_shortener/screens/auth_screen.dart';
import 'package:link_shortener/services/auth_service.dart';
import 'package:link_shortener/widgets/auth/user_profile_header.dart';
import 'package:link_shortener/widgets/feature_section.dart';
import 'package:link_shortener/widgets/url_shortener_form.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.userSession,
  });

  final UserSession? userSession;

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('Building HomeScreen. Authenticated: ${userSession != null}');
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Link Shortener'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          // Show different UI based on authentication state
          if (userSession != null)
            UserProfileHeader(
              user: userSession!.user,
              onSignOut: () => _handleSignOut(context),
            )
          else
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AuthScreen(),
                  ),
                );
              },
              child: Text(
                'Login',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context),
            const SizedBox(height: 48),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: UrlShortenerForm(),
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
                  'Create short, memorable links that redirect to your long URLs. Share them easily on social media, emails, or messages.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withAlpha(230),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
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
  
  Future<void> _handleSignOut(BuildContext context) async {
    // Show confirmation dialog
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    
    if (shouldSignOut == true) {
      // Sign out using AuthService
      await AuthService().signOut();
      
      // Show confirmation message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have been signed out'),
          ),
        );
      }
    }
  }
}
