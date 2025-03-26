import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terms of Service',
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
              '1. Acceptance of Terms',
              'By accessing and using this website, you accept and agree to be bound by the terms and conditions of this agreement.',
            ),
            _buildSection(
              '2. Use License',
              'Permission is granted to temporarily download one copy of the materials (information or software) on Link Shortener\'s website for personal, non-commercial transitory viewing only.',
            ),
            _buildSection(
              '3. Disclaimer',
              'The materials on Link Shortener\'s website are provided on an \'as is\' basis. Link Shortener makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.',
            ),
            _buildSection(
              '4. Limitations',
              'In no event shall Link Shortener or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on Link Shortener\'s website.',
            ),
            _buildSection(
              '5. Accuracy of Materials',
              'The materials appearing on Link Shortener\'s website could include technical, typographical, or photographic errors. Link Shortener does not warrant that any of the materials on its website are accurate, complete or current.',
            ),
            _buildSection(
              '6. Links',
              'Link Shortener has not reviewed all of the sites linked to its website and is not responsible for the contents of any such linked site. The inclusion of any link does not imply endorsement by Link Shortener of the site.',
            ),
            _buildSection(
              '7. Modifications',
              'Link Shortener may revise these terms of service for its website at any time without notice. By using this website you are agreeing to be bound by the then current version of these terms of service.',
            ),
            _buildSection(
              '8. Governing Law',
              'These terms and conditions are governed by and construed in accordance with the laws and you irrevocably submit to the exclusive jurisdiction of the courts in that location.',
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
