import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
                    'Terms of Service',
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
                    '1. Acceptance of Terms',
                    'By accessing or using our URL shortening service, you agree to be bound by these Terms of Service. If you disagree with any part of these terms, you may not access the service.',
                  ),
                  _buildSection(
                    context,
                    '2. Service Description',
                    'We provide a free URL shortening service that allows users to create shortened versions of long URLs. The service is available both with and without authentication. Authentication is provided exclusively through third-party services (Google, Apple, and GitHub). Authenticated users receive additional features including custom retention periods, URL management, and basic analytics.',
                  ),
                  _buildSection(
                    context,
                    '3. Authentication',
                    'To access authenticated features, you must sign in using one of our supported third-party authentication providers (Google, Apple, or GitHub). By using these authentication services, you agree to their respective terms of service and privacy policies. We store only the basic profile information that these services provide (user ID, email address, name, and profile photo URL) for the purpose of providing our service.',
                  ),
                  _buildSection(
                    context,
                    '4. Communications',
                    'By using our service, you agree to receive communications from us, including promotional materials, technical updates, and legal information. You can manage your communication preferences and opt out of promotional emails at any time through your account settings in the user dashboard. We will always include an unsubscribe link in our promotional emails.',
                  ),
                  _buildSection(
                    context,
                    '5. Usage Limitations',
                    'Authenticated users are limited to creating 200 active shortened URLs. This limit may be adjusted at our discretion. We also implement undisclosed security limits on user actions to prevent abuse. We reserve the right to delete any URLs that have been inactive for more than one year.',
                  ),
                  _buildSection(
                    context,
                    '6. Data Retention',
                    'For non-authenticated users, shortened URLs automatically expire after 3 months. Authenticated users can choose their preferred retention period, ranging from 3 months to unlimited. We reserve the right to modify these retention periods with notice to users.',
                  ),
                  _buildSection(
                    context,
                    '7. Prohibited Uses',
                    'While we do not actively monitor shortened URLs, you agree not to use the service for any unlawful purposes or in any way that could damage, disable, overburden, or impair the service. We reserve the right to terminate access for users who violate these terms.',
                  ),
                  _buildSection(
                    context,
                    '8. Service Availability',
                    'We strive to provide a reliable service but do not guarantee uninterrupted access. We may modify, suspend, or discontinue any aspect of the service at any time, including the entire service, without prior notice or liability.',
                  ),
                  _buildSection(
                    context,
                    '9. Third-Party Services',
                    'Our service uses Google reCAPTCHA and Cloudflare for security purposes. By using our service, you also agree to be bound by their respective terms of service.',
                  ),
                  _buildSection(
                    context,
                    '10. Advertising',
                    'We may display third-party advertisements on our website. We are not responsible for the content of these advertisements or any products or services they promote.',
                  ),
                  _buildSection(
                    context,
                    '11. Disclaimer of Warranties',
                    'The service is provided "as is" without any warranties of any kind. We do not guarantee that shortened URLs will remain accessible for any specific period, even within stated retention periods.',
                  ),
                  _buildSection(
                    context,
                    '12. Limitation of Liability',
                    'To the fullest extent permitted by law, we shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use or inability to use the service.',
                  ),
                  _buildSection(
                    context,
                    '13. Changes to Terms',
                    'We reserve the right to modify these terms at any time. Continued use of the service after any such changes constitutes your acceptance of the new terms.',
                  ),
                  _buildSection(
                    context,
                    '14. Governing Law',
                    'These terms shall be governed by and construed in accordance with the laws of Spain, without regard to its conflict of law provisions.',
                  ),
                  _buildSection(
                    context,
                    '15. Contact Information',
                    'For any questions about these terms, please contact us at support@truewebber.com.',
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
