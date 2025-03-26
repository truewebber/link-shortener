import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withAlpha(26),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withAlpha(10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Privacy Policy',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Last updated: March 26, 2024',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 32),
                  _buildSection(
                    context,
                    '1. Introduction',
                    'This Privacy Policy explains how we handle any information when you use our URL shortening service. We are committed to protecting your privacy and being transparent about our practices.',
                  ),
                  _buildSection(
                    context,
                    '2. Information Collection',
                    'We collect minimal data necessary for the service to function. For shortened URLs, we only store the original URL, shortened version, and basic usage statistics (click count and user agent information without any personal identifiers). For authenticated users, we store basic profile information provided by third-party authentication services (Google, Apple, or GitHub), including user ID, email address, name, and profile photo URL. We do not use cookies on our website.',
                  ),
                  _buildSection(
                    context,
                    '3. Email Communications',
                    'We may use your email address to send you promotional materials, technical updates, or legal information about our service. You can manage your email preferences and opt out of these communications at any time through your account settings in the user dashboard. We will always include an unsubscribe link in our promotional emails.',
                  ),
                  _buildSection(
                    context,
                    '4. Authentication',
                    'We use third-party authentication services (Google, Apple, and GitHub) to provide secure user authentication. When you sign in through these services, we receive and store basic profile information that you have authorized these services to share. This information is used solely for authentication and service functionality purposes.',
                  ),
                  _buildSection(
                    context,
                    '5. Third-Party Services',
                    'We use several third-party services to provide and secure our service:\n\n• Authentication: Google, Apple, and GitHub for user authentication\n• Security: Google reCAPTCHA and Cloudflare for protection against abuse\n\nThese services may collect and process certain data according to their own privacy policies. We encourage you to review their respective privacy policies to understand how they handle your information.',
                  ),
                  _buildSection(
                    context,
                    '6. Data Storage',
                    'Our servers are currently located in Barcelona, Spain, but may be relocated to other secure locations (such as Google Cloud Platform or Oracle Cloud in the USA) based on service requirements. All data is stored in secure, non-public network environments.',
                  ),
                  _buildSection(
                    context,
                    '7. Data Retention',
                    'For non-authenticated users, shortened URLs are automatically deleted after 3 months. Authenticated users can choose their preferred retention period (from 3 months to unlimited). We reserve the right to delete links that have been inactive for more than one year.',
                  ),
                  _buildSection(
                    context,
                    '8. Security Measures',
                    'We implement various security measures including reCAPTCHA verification, Cloudflare protection, static code analysis, rate limiting, and regular security testing. Our database is hosted in a private network with restricted access.',
                  ),
                  _buildSection(
                    context,
                    '9. Advertising',
                    'We may display advertisements on our website in the future. These advertisements may use their own tracking technologies according to their respective privacy policies.',
                  ),
                  _buildSection(
                    context,
                    '10. User Rights and Choices',
                    'Authenticated users can manage their shortened URLs, view basic analytics, and control retention periods. You can choose to use our service without authentication, but with limited functionality and a fixed 3-month retention period.',
                  ),
                  _buildSection(
                    context,
                    '11. Changes to This Policy',
                    'We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page.',
                  ),
                  _buildSection(
                    context,
                    '12. Contact Information',
                    'For any questions about this privacy policy or our practices, please contact us at support@truewebber.com.',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildSection(BuildContext context, String title, String content) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
}
