// screens/privacy_policy_screen.dart
import 'package:flutter/material.dart';
import 'package:psits_nexus_mobile/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.privacy_tip_outlined,
                size: 80,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'PSITS-NEXUS Privacy Policy',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onBackground,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Last Updated: December 2023',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            const SizedBox(height: 32),

            _buildSection(
              title: '1. Introduction',
              content: 'PSITS-NEXUS ("we", "our", or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and services.',
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: '2. Information We Collect',
              content: 'We collect information that you provide directly to us, including:\n\n'
                  '• Personal Information: Name, email address, student ID, program, year level\n'
                  '• Academic Information: Course details, membership status\n'
                  '• Payment Information: Transaction history, payment status\n'
                  '• Event Participation: Registration for events, attendance records\n'
                  '• Device Information: Device type, operating system, IP address\n'
                  '• Usage Data: App interactions, feature usage, crash reports',
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: '3. How We Use Your Information',
              content: 'We use the collected information to:\n\n'
                  '• Provide and maintain the PSITS-NEXUS services\n'
                  '• Process your membership and event registrations\n'
                  '• Send important updates and notifications\n'
                  '• Improve our app performance and user experience\n'
                  '• Ensure compliance with PSITS organization policies\n'
                  '• Communicate with you about support requests',
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: '4. Data Security',
              content: 'We implement appropriate technical and organizational security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. All data transmission is encrypted using SSL/TLS protocols.',
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: '5. Data Retention',
              content: 'We retain your personal information for as long as necessary to fulfill the purposes outlined in this Privacy Policy, unless a longer retention period is required or permitted by law. Membership data is retained for the duration of your enrollment plus 5 years for alumni records.',
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: '6. Third-Party Services',
              content: 'We may use third-party services that collect information used to identify you. These services include:\n\n'
                  '• Cloud hosting providers for data storage\n'
                  '• Analytics services to improve app performance\n'
                  '• Payment processors for financial transactions\n\n'
                  'All third-party services are bound by confidentiality agreements and are prohibited from using your personal information for any purpose other than providing services to us.',
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: '7. Your Rights',
              content: 'You have the right to:\n\n'
                  '• Access your personal information\n'
                  '• Correct inaccurate or incomplete data\n'
                  '• Request deletion of your data\n'
                  '• Object to processing of your data\n'
                  '• Request data portability\n'
                  '• Withdraw consent at any time\n\n'
                  'To exercise these rights, contact us at privacy@psits-nexus.com',
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: '8. Children\'s Privacy',
              content: 'Our services are intended for college students who are members of PSITS. We do not knowingly collect information from children under 13. If you believe we have collected information from a child under 13, please contact us immediately.',
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: '9. Changes to This Policy',
              content: 'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last Updated" date. You are advised to review this Privacy Policy periodically for any changes.',
            ),
            const SizedBox(height: 24),

            _buildSection(
              title: '10. Contact Us',
              content: 'If you have any questions about this Privacy Policy, please contact us:\n\n'
                  '• Email: privacy@psits-nexus.com\n'
                  '• Address: PSITS Office, University of Southern Mindanao, Kabacan, North Cotabato\n'
                  '• Phone: (064) 248-1234\n'
                  '• Office Hours: Monday-Friday, 8:00 AM - 5:00 PM',
            ),
            const SizedBox(height: 40),

            // Agreement
            Card(
              color: AppTheme.primaryColor.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.verified_user,
                      size: 40,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Your Privacy Matters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'By using PSITS-NEXUS, you acknowledge that you have read and understood this Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.onBackground,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 15,
            color: AppTheme.onSurface.withOpacity(0.8),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}