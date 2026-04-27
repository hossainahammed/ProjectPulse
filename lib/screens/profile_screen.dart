import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../widgets/glass_background.dart';
import 'subscription_screen.dart';
import 'notes_screen.dart';
import 'notification_screen.dart';
import '../controllers/notification_controller.dart';
import '../controllers/user_controller.dart';
import 'learning_progress_screen.dart';
import 'job_post_list_screen.dart';

class ProfileScreen extends StatelessWidget {
  final bool showBackButton;
  const ProfileScreen({super.key, this.showBackButton = true});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();
    final isWide = MediaQuery.of(context).size.width > 600;
    final padding = isWide ? MediaQuery.of(context).size.width * 0.1 : 24.0;

    return Scaffold(
      body: GlassBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: 24.0),
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 32),
                _buildProfileCard(context),
                const SizedBox(height: 32),
                _buildMenuSection(context, 'Personal Info', [
                  _MenuItem(
                    Icons.person_outline,
                    'Personal Data',
                    () => Get.to(() => const PersonalDataScreen()),
                  ),
                  _MenuItem(
                    Icons.work_outline_rounded,
                    'Recent Job Posts',
                    () => Get.to(() => const JobPostListScreen()),
                  ),
                  _MenuItem(
                    Icons.credit_card_outlined,
                    'Payment History',
                    () => Get.to(() => const PaymentHistoryScreen()),
                  ),
                  _MenuItem(
                    Icons.workspace_premium_outlined,
                    'Subscription',
                    () => Get.to(() => const SubscriptionScreen()),
                  ),
                  _MenuItem(
                    Icons.trending_up_rounded,
                    'Learning Progress',
                    () => Get.to(() => const LearningProgressScreen()),
                  ),
                ]),
                const SizedBox(height: 24),
                _buildMenuSection(context, 'Security', [
                  _MenuItem(
                    Icons.lock_outline,
                    'Security',
                    () => Get.to(() => const SecurityScreen()),
                  ),
                  _MenuItem(
                    Icons.notifications_none_rounded,
                    'Notification Settings',
                    () => Get.to(() => const NotificationSettingsScreen()),
                  ),
                ]),
                const SizedBox(height: 24),
                _buildMenuSection(context, 'Support & About', [
                  _MenuItem(
                    Icons.note_alt_outlined,
                    'My Notes',
                    () => Get.to(() => const NotesScreen()),
                  ),
                  _MenuItem(
                    Icons.help_outline,
                    'Contact Us',
                    () => Get.to(() => const ContactUsScreen()),
                  ),
                  _MenuItem(Icons.brightness_6_outlined, 'Dark Mode', () {
                    final isDark = Get.isDarkMode;
                    Get.find<UserController>().setDarkMode(!isDark);
                  }, isToggle: true),
                ]),
                const SizedBox(height: 32),
                _buildLogoutButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (showBackButton)
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: () => Get.back(),
              ),
            const Text(
              'Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined)),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final UserController userController = Get.find<UserController>();
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Get.theme.colorScheme.primary,
                    Get.theme.colorScheme.secondary,
                  ],
                ),
              ),
              child: const CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/images/user_profile.png'),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _showImageSourceDialog(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Hossain Ahammed',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              if (userController.isPremium.value) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD946EF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        Text('hossain@example.com', style: TextStyle(color: Colors.grey[500])),
      ],
    );
  }

  void _showImageSourceDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Get.isDarkMode ? const Color(0xFF1E1E2C) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Image Source',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  Icons.camera_alt_rounded,
                  'Camera',
                  ImageSource.camera,
                ),
                _buildSourceOption(
                  Icons.photo_library_rounded,
                  'Gallery',
                  ImageSource.gallery,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption(IconData icon, String label, ImageSource source) {
    return GestureDetector(
      onTap: () async {
        Get.back();
        final picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: source);
        if (image != null) {
          Get.snackbar(
            'Success',
            'Profile image updated (simulated)',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Get.theme.colorScheme.primary, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    String title,
    List<_MenuItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(0.05),
            ),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    onTap: item.onTap,
                    leading: Icon(
                      item.icon,
                      color: Get.theme.colorScheme.primary,
                    ),
                    title: Text(item.title),
                    trailing: item.isToggle
                        ? Switch(
                            value: Get.isDarkMode,
                            onChanged: (_) => item.onTap(),
                          )
                        : const Icon(Icons.chevron_right_rounded, size: 20),
                  ),
                  if (index < items.length - 1)
                    Divider(
                      height: 1,
                      indent: 56,
                      color: Colors.grey.withOpacity(0.1),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextButton.icon(
        onPressed: () => _showLogoutDialog(),
        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
        label: const Text(
          'Logout ',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Get.isDarkMode ? const Color(0xFF1E1E2C) : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: 32,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Logout',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to logout? You will need to login again to access your account.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[500]),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Logout'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isToggle;

  _MenuItem(this.icon, this.title, this.onTap, {this.isToggle = false});
}

// Redesigned Screens from Image
class PersonalDataScreen extends StatelessWidget {
  const PersonalDataScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Personal Data'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => Get.back(),
      ),
    ),
    body: GlassBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/user_profile.png'),
            ),
            const SizedBox(height: 32),
            _buildField('Name', 'MILAKIB AHMED'),
            _buildField('Email', 'milakib@example.com'),
            _buildField(
              'Date of Birth',
              '08 June 1999',
              icon: Icons.calendar_today_outlined,
            ),
            _buildField(
              'Location',
              'Select Your Country',
              icon: Icons.keyboard_arrow_down,
            ),
            const SizedBox(height: 40),
            _buildActionButton('Save', () => Get.back()),
          ],
        ),
      ),
    ),
  );

  Widget _buildField(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (icon != null) Icon(icon, size: 20, color: Colors.grey),
            ],
          ),
          const Divider(height: 16),
        ],
      ),
    );
  }
}

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Security'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => Get.back(),
      ),
    ),
    body: GlassBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            ListTile(
              title: const Text('Remember Me'),
              trailing: Switch(value: true, onChanged: (v) {}),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              title: const Text('Change Password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Get.to(() => const ChangePasswordScreen()),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 100),
            _buildActionButton(
              'Change Password',
              () => Get.to(() => const ChangePasswordScreen()),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Change Password'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => Get.back(),
      ),
    ),
    body: GlassBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create new password',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Your new password must be unique from those previously used.',
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 32),
            _buildTextField('Old Password'),
            _buildTextField('New Password'),
            _buildTextField('Confirm Password'),
            const SizedBox(height: 40),
            _buildActionButton('Reset Password', () => Get.back()),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );

  Widget _buildTextField(String hint) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        obscureText: true,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Contact Us'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => Get.back(),
      ),
    ),
    body: GlassBackground(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildTextField('Name'),
            _buildTextField('Email'),
            _buildTextField('Phone'),
            _buildTextField('How can we help?', maxLines: 5),
            const SizedBox(height: 40),
            _buildActionButton('Send', () => Get.back()),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );

  Widget _buildTextField(String hint, {int maxLines = 1}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

Widget _buildActionButton(String label, VoidCallback onTap) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD946EF), // Fuchsia 500
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
  );
}

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController controller =
        Get.find<NotificationController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: GlassBackground(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Preference Settings',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage how you receive alerts and reminders.',
                style: TextStyle(color: Colors.grey[500]),
              ),
              const SizedBox(height: 32),
              _buildSettingGroup([
                Obx(
                  () => _buildToggleItem(
                    'All Notifications',
                    'Turn on/off all alerts',
                    controller.allEnabled.value,
                    (val) => controller.toggleAll(val),
                  ),
                ),
                const Divider(height: 1),
                Obx(
                  () => _buildToggleItem(
                    'Project Completion',
                    'Alert when a project is fully delivered',
                    controller.projectCompleteEnabled.value,
                    (val) => controller.projectCompleteEnabled.value = val,
                  ),
                ),
                const Divider(height: 1),
                Obx(
                  () => _buildToggleItem(
                    'Deadline Reminders',
                    'Notify 2 days before any deadline',
                    controller.deadlineAlertsEnabled.value,
                    (val) => controller.deadlineAlertsEnabled.value = val,
                  ),
                ),
                const Divider(height: 1),
                Obx(
                  () => _buildToggleItem(
                    'Project Creation',
                    'Confirmations for new projects',
                    controller.projectCreateEnabled.value,
                    (val) => controller.projectCreateEnabled.value = val,
                  ),
                ),
              ]),
              const SizedBox(height: 32),
              _buildNavigateButton(
                'View Notification List',
                () => Get.to(() => NotificationScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildToggleItem(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFD946EF),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigateButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFD946EF).withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFD946EF).withOpacity(0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.list_alt_rounded, color: Color(0xFFD946EF)),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFD946EF),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Payment History'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => Get.back(),
      ),
    ),
    body: const GlassBackground(child: Center(child: Text('Payment History'))),
  );
}

class ProfilePhotoScreen extends StatelessWidget {
  const ProfilePhotoScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Profile Photo'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => Get.back(),
      ),
    ),
    body: const GlassBackground(child: Center(child: Text('Profile Photo'))),
  );
}
