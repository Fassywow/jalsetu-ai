import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last Updated: November 30, 2024',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            _buildSection(
              '1. Introduction',
              'Fish Identifier ("we", "our", or "us") respects your privacy and is committed to protecting your personal data. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
            ),
            _buildSection(
              '2. Information We Collect',
              'We collect several types of information to provide and improve our service:\n\n**Personal Information:**\n• Name\n• Phone number\n• Age\n• Years of fishing experience\n• Location/region\n\n**Fishing Data:**\n• Fish species identified\n• Catch counts\n• GPS coordinates of catches\n• Photos of fish catches\n• Session timestamps\n• Vessel ID (if provided)\n\n**Technical Data:**\n• Device information\n• App usage statistics\n• Crash reports\n• Network connectivity status',
            ),
            _buildSection(
              '3. How We Collect Information',
              'We collect information through:\n\n• Direct input during registration and profile updates\n• Automatic collection when you use the app\'s features\n• GPS sensors for location data\n• Camera for fish photos\n• Local storage on your device\n• Cloud synchronization when online',
            ),
            _buildSection(
              '4. How We Use Your Information',
              'We use the collected information to:\n\n• Provide fish species identification services\n• Store and track your fishing session history\n• Synchronize data across devices\n• Improve our machine learning models\n• Generate catch statistics and insights\n• Provide customer support\n• Send important service updates\n• Comply with legal obligations\n• Improve app functionality and user experience',
            ),
            _buildSection(
              '5. Data Storage',
              'Your data is stored in two ways:\n\n**Local Storage:**\n• Data is stored on your device using encrypted local storage\n• Enables offline functionality\n• You control local data deletion\n\n**Cloud Storage:**\n• Data is synchronized to Firebase Cloud Firestore when online\n• Secured with industry-standard encryption\n• Allows data recovery and multi-device access\n• Images are stored using ImageKit cloud storage',
            ),
            _buildSection(
              '6. Data Sharing and Disclosure',
              'We do NOT sell your personal information. We may share data only in the following circumstances:\n\n• With your consent\n• To comply with legal obligations\n• To protect our rights and prevent fraud\n• With service providers (e.g., Firebase, ImageKit) who assist in app functionality\n• Anonymized data for research and improving ML models',
            ),
            _buildSection(
              '7. GPS and Location Data',
              'The app collects GPS coordinates to:\n\n• Record where fish were caught\n• Work offline without internet-based geocoding\n• Provide accurate catch location logs\n\nYou can:\n• Manually enter location names instead of using GPS\n• Deny location permissions (some features may be limited)\n• Location data is stored with latitude/longitude coordinates',
            ),
            _buildSection(
              '8. Photo and Camera Data',
              'When you take photos of fish:\n\n• Photos are used for species identification\n• Stored locally and in cloud storage\n• Used to train and improve our AI models (anonymized)\n• You can delete photos from your session history\n• Photos may contain EXIF data including GPS coordinates',
            ),
            _buildSection(
              '9. Offline Data Collection',
              'The app functions offline by:\n\n• Storing all data locally on your device\n• Automatically syncing when internet is restored\n• No data is lost during offline usage\n• You remain in full control of offline data',
            ),
            _buildSection(
              '10. Data Security',
              'We implement appropriate security measures:\n\n• Encrypted data transmission (HTTPS/TLS)\n• Secure authentication\n• Regular security audits\n• Access controls and authentication\n• Device-level encryption for local storage\n\nHowever, no method of transmission over the internet is 100% secure.',
            ),
            _buildSection(
              '11. Your Rights',
              'You have the right to:\n\n• Access your personal data\n• Correct inaccurate data\n• Delete your account and data\n• Export your fishing session data\n• Opt-out of data collection (may limit functionality)\n• Withdraw consent at any time',
            ),
            _buildSection(
              '12. Data Retention',
              'We retain your information:\n\n• As long as your account is active\n• For the period necessary to provide services\n• To comply with legal obligations\n• You may request data deletion at any time through app settings',
            ),
            _buildSection(
              '13. Children\'s Privacy',
              'Our App is not intended for children under 13. We do not knowingly collect data from children . If we discover such data has been collected, we will delete it immediately.',
            ),
            _buildSection(
              '14. Third-Party Services',
              'The App uses third-party services:\n\n• **Firebase**: Data storage and authentication\n• **ImageKit**: Image hosting and delivery\n• **Google Fonts**: Typography\n\nThese services have their own privacy policies governing their use of information.',
            ),
            _buildSection(
              '15. Changes to Privacy Policy',
              'We may update this Privacy Policy periodically. We will notify you of significant changes through the app. Continued use after changes constitutes acceptance.',
            ),
            _buildSection(
              '16. Contact Us',
              'If you have questions or concerns about this Privacy Policy or our data practices, please contact us through the app support section.',
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                '© 2024 Fish Identifier. All rights reserved.',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.outfit(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
