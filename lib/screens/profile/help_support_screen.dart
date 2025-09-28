import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Help & Support Header
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowDark.withValues(alpha: 0.4),
                    offset: const Offset(0, 16),
                    blurRadius: 40,
                    spreadRadius: 6,
                  ),
                  BoxShadow(
                    color: AppColors.shadowDark.withValues(alpha: 0.25),
                    offset: const Offset(0, 8),
                    blurRadius: 24,
                    spreadRadius: 3,
                  ),
                  BoxShadow(
                    color: AppColors.shadowDark.withValues(alpha: 0.15),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.help_outline,
                      color: AppColors.primaryGreen,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📌 Help & Support',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Find answers to common questions',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // FAQs Section
            _buildSectionHeader('📖 FAQs'),
            _buildFAQItem(
              '1. How to register and login?',
              'Open the app and click Register.\n\nFill in your name, address, email, and password.\n\nAfter registration, use your email and password to Login.',
            ),
            _buildFAQItem(
              '2. How to track garbage collection schedule?',
              'Go to the Track tab at the bottom menu.\n\nSelect your barangay to see the collection schedule.',
            ),
            _buildFAQItem(
              '3. How to report missed garbage collection?',
              'Go to the Report Status option in your Profile.\n\nFill in the details (location, date, concern).\n\nYou may also upload a photo for proof',
            ),
            _buildFAQItem(
              '4. What to do if the app is not loading or offline?',
              'Check your internet connection.\n\nRestart the app.\n\nIf the problem continues, try again later since the server may be under maintenance.',
            ),
            _buildFAQItem(
              '5. How to update my profile or account?',
              'Go to the Profile tab.\n\nClick Edit Profile.\n\nUpdate your information and press Save',
            ),

            const SizedBox(height: 32),

            // Contact Support Section
            _buildSectionHeader('📞 Contact Support'),
            _buildContactCard(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.4),
            offset: const Offset(0, 16),
            blurRadius: 40,
            spreadRadius: 6,
          ),
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.25),
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: 3,
          ),
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.15),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          iconColor: AppColors.primaryGreen,
          collapsedIconColor: AppColors.textSecondary,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.4),
            offset: const Offset(0, 16),
            blurRadius: 40,
            spreadRadius: 6,
          ),
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.25),
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: 3,
          ),
          BoxShadow(
            color: AppColors.shadowDark.withValues(alpha: 0.15),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContactItem(
            Icons.email_outlined,
            'Email',
            'support@greentagbilaran.app',
          ),
          const SizedBox(height: 16),
          _buildContactItem(Icons.phone_outlined, 'Phone', '+63 917 555 0101'),
          const SizedBox(height: 16),
          _buildContactItem(
            Icons.message_outlined,
            'Facebook/Messenger',
            'm.me/GreenTagbilaranOfficial',
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: AppColors.primaryGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Operating Hours',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Mon–Fri: 8:00 AM – 5:00 PM\nSat: 8:00 AM – 12:00 PM\nSun & Holidays: Closed',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primaryGreen, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
