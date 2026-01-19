import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

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
          'Terms & Conditions',
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
              'Terms and Conditions of Use',
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
              '1. Acceptance of Terms',
              'By accessing and using the Fish Identifier application ("App"), you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to these Terms and Conditions, please do not use our App.',
            ),
            _buildSection(
              '2. Use of the Application',
              'The Fish Identifier App is designed to help fishermen identify fish species, track their catches, and maintain fishing session records. You agree to use the App only for lawful purposes and in accordance with these Terms.',
            ),
            _buildSection(
              '3. User Accounts',
              'To use certain features of the App, you may be required to register for an account. You agree to:\n\n• Provide accurate, current, and complete information during registration\n• Maintain the security of your account credentials\n• Accept responsibility for all activities that occur under your account\n• Notify us immediately of any unauthorized use of your account',
            ),
            _buildSection(
              '4. Fish Identification',
              'While we strive to provide accurate fish species identification using advanced YOLOv8 machine learning technology:\n\n• The App provides identification for educational and informational purposes only\n• We do not guarantee 100% accuracy in fish species identification\n• Users should verify identifications with local authorities when required\n• The App should not be the sole basis for regulatory compliance decisions',
            ),
            _buildSection(
              '5. Data Collection and Storage',
              'The App collects and stores fishing session data including:\n\n• Fish species identified\n• Approximate catch counts\n• GPS location data\n• Photos of catches\n• Session timestamps\n\nThis data is stored both locally on your device and synchronized with our cloud services when internet access is available.',
            ),
            _buildSection(
              '6. Offline Functionality',
              'The App is designed to work offline. Data captured while offline will be automatically synchronized when an internet connection becomes available.',
            ),
            _buildSection(
              '7. User Responsibilities',
              'Users must:\n\n• Comply with all applicable fishing regulations and laws\n• Obtain necessary fishing licenses and permits\n• Report catches accurately\n• Respect catch limits and protected species\n• Report any bugs or  issues to improve the app',
            ),
            _buildSection(
              '8. Prohibited Activities',
              'You may not:\n\n• Use the App for illegal fishing activities\n• Manipulate or falsify catch data\n• Reverse engineer or attempt to extract the source code\n• Use the App to harm marine ecosystems\n• Share your account credentials with others',
            ),
            _buildSection(
              '9. Intellectual Property',
              'All content in the App, including but not limited to text, graphics, logos, images, and software, is the property of Fish Identifier or its licensors and protected by copyright and intellectual property laws.',
            ),
            _buildSection(
              '10. Limitation of Liability',
              'The App is provided "as is" without warranties of any kind. We shall not be liable for any damages arising from the use or inability to use the App, including but not limited to:\n\n• Incorrect fish identification\n• Data loss\n• Missed catches due to app malfunction\n• Regulatory fines resulting from reliance on app data',
            ),
            _buildSection(
              '11. Modifications to Terms',
              'We reserve the right to modify these Terms at any time. Continued use of the App after changes constitutes acceptance of the modified Terms.',
            ),
            _buildSection(
              '12. Termination',
              'We may terminate or suspend your account and access to the App immediately, without prior notice, for conduct that we believe violates these Terms or is harmful to other users, us, or third parties.',
            ),
            _buildSection(
              '13. Contact Information',
              'For questions about these Terms and Conditions, please contact us through the App support section.',
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
