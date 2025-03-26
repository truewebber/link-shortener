import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:link_shortener/services/auth_service.dart';
import 'package:link_shortener/services/url_service.dart';
import 'package:link_shortener/widgets/feature_section.dart';
import 'package:link_shortener/widgets/url_shortener_form.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.authService,
    required this.urlService,
  });

  final AuthService authService;
  final UrlService urlService;

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print(
          'Building HomeScreen. Authenticated: ${authService.currentSession != null}');
    }

    return Column(
      children: [
        _buildHeroSection(context),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                const SizedBox(height: 48),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      if (authService.currentSession != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: _buildAuthenticatedBanner(context),
                        ),
                      UrlShortenerForm(
                        isAuthenticated: authService.currentSession != null,
                        urlService: urlService,
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
        ),
      ],
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
                    'Welcome back${authService.currentSession?.user?.name != null ? ', ${authService.currentSession!.user!.name}' : ''}!',
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
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed('/urls');
              },
              icon: const Icon(Icons.link),
              label: const Text('My Links'),
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
            stops: const [0.0, 0.4, 0.8, 1.0],
            colors: [
              Theme.of(context).colorScheme.primary.withBlue(
                    Theme.of(context).colorScheme.primary.b.hashCode + 20,
                  ),
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withAlpha(230),
              Theme.of(context).colorScheme.primary.withAlpha(200),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withAlpha(77),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
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
                    authService.currentSession != null
                        ? 'Create short, memorable links with full control over expiration and tracking features.'
                        : 'Create short, memorable links that redirect to your long URLs. Share them easily on social media, emails, or messages.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withAlpha(230),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (authService.currentSession == null) ...[
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/auth'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
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
}
