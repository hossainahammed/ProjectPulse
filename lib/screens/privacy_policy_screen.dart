import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/glass_background.dart';
import '../controllers/user_controller.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Get.find<UserController>().isDarkMode.value;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final cardBgColor = isDark
        ? const Color(0xFF1E293B).withValues(alpha: 0.7)
        : Colors.white.withValues(alpha: 0.7);
    final borderColor = isDark ? Colors.white10 : Colors.grey.shade200;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor:
          Colors.transparent, // Let GlassBackground handle background color
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GlassBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIntroSection(isDark, textColor),
                const SizedBox(height: 24),
                _PolicySection(
                  icon: Icons.info_outline_rounded,
                  title: '1. Information We Collect',
                  paragraphs: const [
                    'Personal Profile Information: When you create or update your account, we collect personal data including your name, email address, date of birth, location, and profile photo.',
                    'Project and Task Management Data: To provide core services, we store your projects, tasks, milestones, notes, KPIs, and financial estimates/calculators that you input.',
                    'Push Notification Tokens: We collect and register Firebase Cloud Messaging (FCM) tokens to deliver real-time deadline warnings and project progress updates.',
                    'Automated Usage Data: We collect analytics (such as pages viewed, session durations) and crash logs using Firebase Analytics and Crashlytics to improve application performance.'
                  ],
                  cardBgColor: cardBgColor,
                  borderColor: borderColor,
                  textColor: textColor,
                ),
                const SizedBox(height: 16),
                _PolicySection(
                  icon: Icons.settings_suggest_outlined,
                  title: '2. How We Use Your Data',
                  paragraphs: const [
                    'To deliver, operate, and maintain the ProjectPulse task management environment.',
                    'To notify you of upcoming project deadlines, milestone achievements, and administrative updates through local and push notifications.',
                    'To personalize your user experience, including theme preferences (Dark/Light mode) and profile customization.',
                    'To detect, prevent, and debug software crashes and system issues via Crashlytics.'
                  ],
                  cardBgColor: cardBgColor,
                  borderColor: borderColor,
                  textColor: textColor,
                ),
                const SizedBox(height: 16),
                _PolicySection(
                  icon: Icons.cloud_done_outlined,
                  title: '3. Cloud Services & Third-Parties',
                  paragraphs: const [
                    'ProjectPulse uses Google Firebase for hosting, authentication, storage, database (Firestore), and push notification dispatch.',
                    'We do not sell, rent, or trade your personal profile data, projects, or notes to third-party advertising companies.',
                    'Your data is securely transmitted and stored on cloud servers managed by Google Firebase with robust access control security policies.'
                  ],
                  cardBgColor: cardBgColor,
                  borderColor: borderColor,
                  textColor: textColor,
                ),
                const SizedBox(height: 16),
                _PolicySection(
                  icon: Icons.security_outlined,
                  title: '4. Data Security & Retention',
                  paragraphs: const [
                    'Offline Caching: ProjectPulse utilizes local Firestore offline cache persistence, enabling your data to remain secure on your device even without an active internet connection.',
                    'Authentication: Standard OAuth and secure email verification are enforced. Password details are managed entirely by Firebase Authentication.',
                    'Data Retention: We retain your account information and associated project logs for as long as your account remains active. You can request deletion at any time.'
                  ],
                  cardBgColor: cardBgColor,
                  borderColor: borderColor,
                  textColor: textColor,
                ),
                const SizedBox(height: 16),
                _PolicySection(
                  icon: Icons.delete_sweep_outlined,
                  title: '5. Your Rights & Choices',
                  paragraphs: const [
                    'You have the right to access, update, or correct your personal data directly through the Profile tab in the application.',
                    'You can toggle push notification categories or opt out of notifications entirely in the Notification Settings screen.',
                    'To request complete deletion of your account and all associated project data, please contact the developer team or trigger account closure in settings.'
                  ],
                  cardBgColor: cardBgColor,
                  borderColor: borderColor,
                  textColor: textColor,
                ),
                const SizedBox(height: 24),
                _buildContactCard(cardBgColor, borderColor, textColor),
                const SizedBox(height: 48),
                Center(
                  child: Text(
                    'Last Updated: June 11, 2026\nVersion 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroSection(bool isDark, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.privacy_tip_outlined,
                color: Get.theme.colorScheme.primary,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ProjectPulse',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Privacy Commitment',
                    style: TextStyle(
                      fontSize: 14,
                      color: Get.theme.colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'At ProjectPulse, we value your privacy. This Privacy Policy details how we collect, store, utilize, and protect your information when using our freelance and project management mobile application.',
          style: TextStyle(
            fontSize: 15,
            color: textColor.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard(
      Color cardColor, Color borderColor, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.mail_outline_rounded,
                  color: Get.theme.colorScheme.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'Contact the Developer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'If you have any questions or feedback regarding this Privacy Policy or data handling, please get in touch with us:',
            style: TextStyle(
              fontSize: 14,
              color: textColor.withValues(alpha: 0.75),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Developer Email: ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              Expanded(
                child: Text(
                  'hossainahammed@example.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: Get.theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> paragraphs;
  final Color cardBgColor;
  final Color borderColor;
  final Color textColor;

  const _PolicySection({
    required this.icon,
    required this.title,
    required this.paragraphs,
    required this.cardBgColor,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Get.theme.colorScheme.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...paragraphs.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0, right: 10.0),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Get.theme.colorScheme.secondary
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        p,
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor.withValues(alpha: 0.8),
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
