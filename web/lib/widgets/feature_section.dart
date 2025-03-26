import 'package:flutter/material.dart';

class FeatureSection extends StatelessWidget {
  const FeatureSection({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Text(
              'Features',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 900;
                final isTablet = constraints.maxWidth > 600;
                final crossAxisCount = isDesktop ? 3 : (isTablet ? 2 : 1);

                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 24,
                  childAspectRatio: 1.5,
                  children: [
                    _buildFeatureCard(
                      context,
                      icon: Icons.link,
                      title: 'Short Links',
                      description:
                          'Create short, memorable links that are easy to share.',
                    ),
                    _buildFeatureCard(
                      context,
                      icon: Icons.timer,
                      title: 'Custom Expiration',
                      description:
                          'Set custom expiration times for your links.',
                    ),
                    _buildFeatureCard(
                      context,
                      icon: Icons.analytics,
                      title: 'Link Analytics',
                      description:
                          'Track clicks and view detailed analytics for your links.',
                    ),
                    _buildFeatureCard(
                      context,
                      icon: Icons.security,
                      title: 'Secure Links',
                      description:
                          'All links are encrypted and secure by default.',
                    ),
                    _buildFeatureCard(
                      context,
                      icon: Icons.devices,
                      title: 'Cross-Platform',
                      description:
                          'Access your links from any device or platform.',
                    ),
                    _buildFeatureCard(
                      context,
                      icon: Icons.speed,
                      title: 'Fast Redirection',
                      description:
                          'Lightning-fast redirection to your destination URLs.',
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      );

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) =>
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow..withAlpha(26),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withAlpha(179),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}
