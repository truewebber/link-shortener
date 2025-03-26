import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Last updated: March 26, 2024',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              '1. Information We Collect',
              'We collect information that you provide directly to us, including when you create an account, use our services, or communicate with us. This may include your name, email address, and any other information you choose to provide.',
            ),
            _buildSection(
              '2. How We Use Your Information',
              'We use the information we collect to provide, maintain, and improve our services, to communicate with you, and to develop new ones. We also use this information to protect our platform and our users.',
            ),
            _buildSection(
              '3. Information Sharing',
              'We do not share your personal information with companies, organizations, or individuals outside of Link Shortener except in the following cases: with your consent, for legal reasons, or as part of a business transfer.',
            ),
            _buildSection(
              '4. Data Security',
              'We work hard to protect our users from unauthorized access to or unauthorized alteration, disclosure, or destruction of information we hold.',
            ),
            _buildSection(
              '5. Data Retention',
              'We retain your information for as long as necessary to provide our services and comply with legal obligations. When we no longer need your information, we will delete it.',
            ),
            _buildSection(
              '6. Your Rights',
              'You have the right to access, correct, or delete your personal information. You can also object to our use of your information or withdraw your consent at any time.',
            ),
            _buildSection(
              '7. Cookies',
              'We use cookies and similar technologies to collect and store information when you visit our website. You can control how cookies are used through your browser settings.',
            ),
            _buildSection(
              '8. Changes to This Policy',
              'Our Privacy Policy may change from time to time. We will post any privacy policy changes on this page and, if the changes are significant, we will provide a more prominent notice.',
            ),
            _buildSection(
              '9. Contact Us',
              'If you have any questions about this Privacy Policy, please contact us at ask@twb.one',
            ),
          ],
        ),
      ),
    );

  Widget _buildSection(String title, String content) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
}
