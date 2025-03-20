import 'package:flutter/material.dart';
import '../widgets/url_shortener_form.dart';
import '../widgets/feature_section.dart';
import 'package:flutter/foundation.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('Building HomeScreen');
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Link Shortener'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          TextButton(
            onPressed: () {
              // This would navigate to login screen in a real app
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Login functionality will be implemented in Sprint 2'),
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
  
  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive layout based on available width
          final isDesktop = constraints.maxWidth > 900;
          final isTablet = constraints.maxWidth > 600;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildRobustFooter(BuildContext context) {
    return Container(
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
  }
  
  // Widget _buildSimpleFooter(BuildContext context) {
  //   return Container(
  //     height: 50,
  //     color: Colors.grey.shade200,
  //     child: const Center(
  //       child: Text(
  //         '© 2024 Link Shortener. All rights reserved.',
  //         style: TextStyle(color: Colors.black),
  //       ),
  //     ),
  //   );
  // }
  
  // Widget _buildFooter(BuildContext context) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
  //     color: Theme.of(context).colorScheme.surface,
  //     child: Center(
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               TextButton(
  //                 onPressed: () {},
  //                 child: const Text('Terms of Service'),
  //               ),
  //               const SizedBox(width: 16),
  //               TextButton(
  //                 onPressed: () {},
  //                 child: const Text('Privacy Policy'),
  //               ),
  //               const SizedBox(width: 16),
  //               TextButton(
  //                 onPressed: () {},
  //                 child: const Text('Contact Us'),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 8),
  //           Text(
  //             '© ${DateTime.now().year} Link Shortener. All rights reserved.',
  //             style: Theme.of(context).textTheme.bodySmall,
  //             textAlign: TextAlign.center,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
} 