import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/glass_background.dart';
import '../controllers/auth_controller.dart';
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
              child: Obx(() {
                final imageUrl = userController.profileImageUrl.value;
                return CircleAvatar(
                  radius: 60,
                  backgroundImage: imageUrl.isNotEmpty
                      ? NetworkImage(imageUrl) as ImageProvider
                      : const AssetImage('assets/images/user_profile.png'),
                );
              }),
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
              Text(
                userController.name.value.isNotEmpty
                    ? userController.name.value
                    : 'User Profile',
                style: const TextStyle(
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
        Obx(() {
          final displayEmail = userController.email.value.isNotEmpty
              ? userController.email.value
              : (FirebaseAuth.instance.currentUser?.email ?? '');
          return Text(
            displayEmail.isNotEmpty ? displayEmail : 'No email set',
            style: TextStyle(color: Colors.grey[500]),
          );
        }),
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
    final UserController userController = Get.find<UserController>();
    return GestureDetector(
      onTap: () async {
        Get.back();
        final picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: source);
        if (image != null) {
          Get.dialog(
            const Center(
              child: CircularProgressIndicator(),
            ),
            barrierDismissible: false,
          );
          
          final success = await userController.uploadProfileImage(File(image.path));
          
          Get.back(); // Close loading dialog
          
          if (success) {
            Get.snackbar(
              'Success 🎉',
              'Profile image updated successfully.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green[600],
              colorText: Colors.white,
            );
          } else {
            Get.snackbar(
              'Error ❌',
              'Failed to upload profile image.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red[600],
              colorText: Colors.white,
            );
          }
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.primary.withValues(alpha: 0.1),
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
              color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
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
                      color: Colors.grey.withValues(alpha: 0.1),
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
        color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
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
                  color: Colors.red.withValues(alpha: 0.1),
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
                      onPressed: () {
                        Get.back(); // Close dialog
                        Get.find<AuthController>().signOut(); // Sign out from Firebase
                      },
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
class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  final UserController _userController = Get.find<UserController>();
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _dobController;
  late final TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _userController.name.value);
    _dobController = TextEditingController(text: _userController.dob.value);
    _locationController = TextEditingController(text: _userController.location.value);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final months = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
      ];
      final dateStr = "${picked.day} ${months[picked.month - 1]} ${picked.year}";
      setState(() {
        _dobController.text = dateStr;
      });
    }
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      
      final success = await _userController.updateUserProfile(
        name: _nameController.text.trim(),
        dob: _dobController.text.trim(),
        location: _locationController.text.trim(),
      );
      
      Get.back(); // close loader
      
      if (success) {
        Get.snackbar(
          'Profile Updated! 🎉',
          'Your profile data has been saved successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[600],
          colorText: Colors.white,
        );
        Get.back(); // return to settings
      } else {
        Get.snackbar(
          'Failed ❌',
          'Could not update profile data.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[600],
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Obx(() {
                  final imageUrl = _userController.profileImageUrl.value;
                  return CircleAvatar(
                    radius: 50,
                    backgroundImage: imageUrl.isNotEmpty
                        ? NetworkImage(imageUrl) as ImageProvider
                        : const AssetImage('assets/images/user_profile.png'),
                  );
                }),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: UnderlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: _userController.email.value,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    helperText: 'Email cannot be changed',
                    border: UnderlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _dobController,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    suffixIcon: Icon(Icons.calendar_today_outlined, size: 20),
                    border: UnderlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location / Country',
                    suffixIcon: Icon(Icons.keyboard_arrow_down, size: 20),
                    border: UnderlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Location is required' : null,
                ),
                const SizedBox(height: 40),
                _buildActionButton('Save', _save),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _rememberMe = true;

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
              trailing: Switch(
                value: _rememberMe,
                onChanged: (v) {
                  setState(() {
                    _rememberMe = v;
                  });
                },
              ),
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

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      // Capture context values before any async gaps
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final primaryColor = Theme.of(context).colorScheme.primary;

      setState(() {
        _isLoading = true;
      });

      try {
        final User? user = FirebaseAuth.instance.currentUser;
        if (user != null && user.email != null) {
          // Reauthenticate the user first
          final AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!,
            password: _oldPasswordController.text,
          );
          
          await user.reauthenticateWithCredential(credential);
          
          // Update the password
          await user.updatePassword(_newPasswordController.text);
          
          if (!mounted) return;
          setState(() {
            _isLoading = false;
          });

          // Show Success dialog
          Get.dialog(
            Dialog(
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline_rounded,
                        color: Colors.green,
                        size: 54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Password Changed! 🎉',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Your password has been successfully updated. Please use your new credentials next time.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back(); // Close Dialog
                          Get.back(); // Pop back to SecurityScreen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'OK',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            barrierDismissible: false,
          );
        } else {
          throw Exception('No authenticated user found.');
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
        });
        String errorMsg = e.message ?? 'An error occurred while changing password.';
        if (e.code == 'wrong-password') {
          errorMsg = 'The old password you entered is incorrect.';
        } else if (e.code == 'weak-password') {
          errorMsg = 'The new password provided is too weak.';
        }
        _showErrorPopup(errorMsg);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorPopup(e.toString());
      }
    }
  }

  void _showErrorPopup(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.dialog(
      Dialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red,
                  size: 54,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Change Failed',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Form(
            key: _formKey,
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
                _buildPasswordField('Old Password', _oldPasswordController, _obscureOld, (v) {
                  setState(() { _obscureOld = !v; });
                }, (v) => v == null || v.isEmpty ? 'Old Password is required' : null),
                _buildPasswordField('New Password', _newPasswordController, _obscureNew, (v) {
                  setState(() { _obscureNew = !v; });
                }, (v) {
                  if (v == null || v.isEmpty) return 'New Password is required';
                  if (v.length < 6) return 'Password must be at least 6 characters';
                  return null;
                }),
                _buildPasswordField('Confirm Password', _confirmPasswordController, _obscureConfirm, (v) {
                  setState(() { _obscureConfirm = !v; });
                }, (v) {
                  if (v == null || v.isEmpty) return 'Confirm your password';
                  if (v != _newPasswordController.text) return 'Passwords do not match';
                  return null;
                }),
                const SizedBox(height: 40),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildActionButton('Reset Password', _submit),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String hint, 
    TextEditingController controller, 
    bool obscure, 
    ValueChanged<bool> onToggleVisibility,
    FormFieldValidator<String> validator,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 20,
            ),
            onPressed: () => onToggleVisibility(obscure),
          ),
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

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _send() async {
    if (_formKey.currentState!.validate()) {
      // Capture context values before async gaps
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final primaryColor = Theme.of(context).colorScheme.primary;

      setState(() {
        _isLoading = true;
      });

      final String name = _nameController.text.trim();
      final String email = _emailController.text.trim();
      final String phone = _phoneController.text.trim();
      final String message = _messageController.text.trim();

      try {
        // 1. Save to Cloud Firestore
        await FirebaseFirestore.instance.collection('contact_messages').add({
          'name': name,
          'email': email,
          'phone': phone,
          'message': message,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // 2. Pre-fill and launch default mail client
        final Uri emailLaunchUri = Uri(
          scheme: 'mailto',
          path: 'hossainahammed627@gmail.com',
          query: 'subject=ProjectPulse%20Support%20Query%20from%20${Uri.encodeComponent(name)}&body=${Uri.encodeComponent("Hi Support,\n\n$message\n\nContact Details:\nPhone: $phone\nEmail: $email")}',
        );

        await launchUrl(emailLaunchUri);

        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        // Show themed success popup
        Get.dialog(
          Dialog(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isDark ? Colors.white10 : Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      color: Colors.green,
                      size: 54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Message Sent! ✉️',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your message has been saved in our system and we are opening your mail client to send it.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Close Dialog
                        Get.back(); // Pop back to Settings
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        Get.snackbar(
          'Error ❌',
          'Failed to send message: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[600],
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildFormTextField('Name', _nameController, (v) => v == null || v.trim().isEmpty ? 'Name is required' : null),
                _buildFormTextField('Email', _emailController, (v) {
                  if (v == null || v.trim().isEmpty) return 'Email is required';
                  if (!GetUtils.isEmail(v.trim())) return 'Enter a valid email';
                  return null;
                }, keyboardType: TextInputType.emailAddress),
                _buildFormTextField('Phone', _phoneController, (v) => v == null || v.trim().isEmpty ? 'Phone is required' : null, keyboardType: TextInputType.phone),
                _buildFormTextField('How can we help?', _messageController, (v) => v == null || v.trim().isEmpty ? 'Message is required' : null, maxLines: 5),
                const SizedBox(height: 40),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildActionButton('Send', _send),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormTextField(
    String hint, 
    TextEditingController controller, 
    FormFieldValidator<String> validator, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        keyboardType: keyboardType,
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
        color: Get.theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
          color: const Color(0xFFD946EF).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFD946EF).withValues(alpha: 0.5)),
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
