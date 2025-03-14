import 'package:flutter/material.dart';

class FeatureSection extends StatelessWidget {
  const FeatureSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Features',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              // Responsive layout based on available width
              if (constraints.maxWidth > 900) {
                // Desktop layout - 3 columns
                final featureItems = _buildFeatureItems(context);
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: featureItems[0]),
                    Expanded(child: featureItems[1]),
                    Expanded(child: featureItems[2]),
                  ],
                );
              } else if (constraints.maxWidth > 600) {
                // Tablet layout - 2 columns
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildFeatureItems(context)[0]),
                        Expanded(child: _buildFeatureItems(context)[1]),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildFeatureItems(context)[2],
                  ],
                );
              } else {
                // Mobile layout - 1 column
                return Column(
                  children: _buildFeatureItems(context)
                      .map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 32),
                            child: item,
                          ))
                      .toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFeatureItems(BuildContext context) {
    return [
      _buildFeatureItem(
        context,
        icon: Icons.speed,
        title: 'Fast & Reliable',
        description:
            'Our service provides quick URL shortening with high availability and minimal latency.',
      ),
      _buildFeatureItem(
        context,
        icon: Icons.analytics,
        title: 'Link Analytics',
        description:
            'Track your link performance with detailed analytics and insights.',
      ),
      _buildFeatureItem(
        context,
        icon: Icons.access_time,
        title: 'Custom Expiration',
        description:
            'Set custom expiration dates for your links when you sign in.',
      ),
    ];
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
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
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 