import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserController extends GetxController with WidgetsBindingObserver {
  final RxBool isPremium = false.obs;
  final RxBool isAdmin = false.obs;
  // Observable theme flag — toggled when user switches theme so Obx rebuilds
  final RxBool isDarkMode = false.obs;

  // Subscription plan type: 'Free', 'Monthly', or 'Yearly'
  final RxString planType = 'Free'.obs;

  // Dynamic subscription pricing (fetched from Firestore /configs/subscription)
  final RxDouble monthlyPrice = 100.0.obs;
  final RxDouble yearlyPrice = 600.0.obs;
  final RxBool isLoadingPricing = false.obs;

  // Reactive user profile properties
  final RxString name = ''.obs;
  final RxString email = ''.obs;
  final RxString dob = ''.obs;
  final RxString location = ''.obs;
  final RxString profileImageUrl = ''.obs;
  final RxBool isLoadingProfile = false.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    // Initialize theme based on system
    isDarkMode.value = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    
    // Fetch pricing config from Firestore (no auth required)
    fetchPricing();
    // If a user is already logged in when this controller starts, seed immediately
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      _seedFromFirebaseUser(currentUser);
      fetchUserProfile(currentUser.uid);
    }
  }

  // Seed basic profile data directly from FirebaseAuth (instant — no Firestore delay)
  void _seedFromFirebaseUser(User user) {
    if (email.value.isEmpty) email.value = user.email ?? '';
    if (name.value.isEmpty) name.value = user.displayName ?? '';
    if (profileImageUrl.value.isEmpty) profileImageUrl.value = user.photoURL ?? '';
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    isDarkMode.value = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    Get.changeThemeMode(ThemeMode.system);
  }

  void togglePremium() {
    isPremium.value = !isPremium.value;
  }

  /// Fetch subscription pricing from Firestore /configs/subscription
  Future<void> fetchPricing() async {
    try {
      isLoadingPricing.value = true;
      final doc = await _firestore.collection('configs').doc('subscription').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        monthlyPrice.value = (data['monthlyPrice'] as num?)?.toDouble() ?? 100.0;
        yearlyPrice.value = (data['yearlyPrice'] as num?)?.toDouble() ?? 600.0;
      }
      isLoadingPricing.value = false;
    } catch (e) {
      isLoadingPricing.value = false;
      debugPrint('fetchPricing error: $e');
    }
  }

  /// Admin-only: update subscription pricing in Firestore
  Future<bool> updatePricing({required double monthly, required double yearly}) async {
    try {
      await _firestore.collection('configs').doc('subscription').set({
        'monthlyPrice': monthly,
        'yearlyPrice': yearly,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      monthlyPrice.value = monthly;
      yearlyPrice.value = yearly;
      return true;
    } catch (e) {
      debugPrint('updatePricing error: $e');
      return false;
    }
  }

  /// Call this whenever the theme mode changes (in ProfileScreen's toggle)
  void setDarkMode(bool value) {
    isDarkMode.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  // Fetch the user's profile document from Firestore
  Future<void> fetchUserProfile(String uid) async {
    try {
      isLoadingProfile.value = true;
      // First, immediately seed from FirebaseAuth so UI is never empty
      final currentUser = _auth.currentUser;
      if (currentUser != null) _seedFromFirebaseUser(currentUser);

      final DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        // Only overwrite if Firestore has a non-empty value
        final fsName = data['name'] as String? ?? '';
        final fsEmail = data['email'] as String? ?? '';
        final fsDob = data['dob'] as String? ?? '';
        final fsLocation = data['location'] as String? ?? '';
        final fsImageUrl = data['profileImageUrl'] as String? ?? '';
        final fsIsPremium = data['isPremium'] as bool? ?? false;
        final fsIsAdmin = data['isAdmin'] as bool? ?? (data['role'] == 'admin');
        final fsPlanType = data['planType'] as String? ?? (fsIsPremium ? 'Monthly' : 'Free');

        if (fsName.isNotEmpty) name.value = fsName;
        if (fsEmail.isNotEmpty) email.value = fsEmail;
        if (fsDob.isNotEmpty) dob.value = fsDob;
        if (fsLocation.isNotEmpty) location.value = fsLocation;
        if (fsImageUrl.isNotEmpty) profileImageUrl.value = fsImageUrl;
        isPremium.value = fsIsPremium;
        isAdmin.value = fsIsAdmin;
        planType.value = fsPlanType;
      }
      isLoadingProfile.value = false;
    } catch (e) {
      isLoadingProfile.value = false;
      debugPrint('Error fetching user profile: $e');
    }
  }

  // Ensure that a user profile document exists in Firestore (useful for Google/Social sign in or fresh signup)
  Future<void> ensureProfileExists(
    String uid, {
    required String name,
    required String email,
    required String profileImageUrl,
  }) async {
    try {
      // Immediately populate in-memory so UI shows data right away
      if (name.isNotEmpty) this.name.value = name;
      if (email.isNotEmpty) this.email.value = email;
      if (profileImageUrl.isNotEmpty) this.profileImageUrl.value = profileImageUrl;

      final docRef = _firestore.collection('users').doc(uid);
      final doc = await docRef.get();
      if (!doc.exists) {
        await docRef.set({
          'name': name,
          'email': email,
          'dob': '',
          'location': '',
          'profileImageUrl': profileImageUrl,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      // Reload from Firestore so we have the full stored profile
      await fetchUserProfile(uid);
    } catch (e) {
      debugPrint('Error ensuring profile exists: $e');
    }
  }

  // Update user profile text fields
  Future<bool> updateUserProfile({
    required String name,
    required String dob,
    required String location,
  }) async {
    try {
      final String? uid = _auth.currentUser?.uid;
      if (uid == null) return false;

      isLoadingProfile.value = true;
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'dob': dob,
        'location': location,
      }, SetOptions(merge: true));

      // Update Firebase Auth display name for consistency
      await _auth.currentUser?.updateDisplayName(name);

      this.name.value = name;
      this.dob.value = dob;
      this.location.value = location;
      
      isLoadingProfile.value = false;
      return true;
    } catch (e) {
      isLoadingProfile.value = false;
      debugPrint('Error updating user profile: $e');
      _handleFirestoreError(e);
      return false;
    }
  }

  // Save profile photo as base64 directly to Firestore (keeps it free without Storage)
  Future<bool> uploadProfileImage(File imageFile) async {
    try {
      final String? uid = _auth.currentUser?.uid;
      if (uid == null) return false;

      isLoadingProfile.value = true;
      
      // Read bytes and convert to Base64 data URL
      final bytes = await imageFile.readAsBytes();
      final base64String = base64Encode(bytes);
      final dataUrl = 'data:image/jpeg;base64,$base64String';
      
      // Update Firestore user document
      await _firestore.collection('users').doc(uid).set({
        'profileImageUrl': dataUrl,
      }, SetOptions(merge: true));

      // Update Firebase Auth photo URL for consistency if within size limits
      try {
        await _auth.currentUser?.updatePhotoURL(dataUrl);
      } catch (authError) {
        debugPrint('Firebase Auth photoURL update failed (usually due to URL length): $authError');
      }

      profileImageUrl.value = dataUrl;
      isLoadingProfile.value = false;
      return true;
    } catch (e) {
      isLoadingProfile.value = false;
      debugPrint('Error saving profile image: $e');
      _handleFirestoreError(e);
      return false;
    }
  }

  // Helper to load profile image from URL or Base64 data URL
  ImageProvider getProfileImageProvider(String imageUrl) {
    if (imageUrl.startsWith('data:image')) {
      try {
        final base64Str = imageUrl.split(',').last;
        return MemoryImage(base64Decode(base64Str));
      } catch (e) {
        return const AssetImage('assets/images/user_profile.png');
      }
    }
    return NetworkImage(imageUrl);
  }

  // Reset observable state on sign out
  void clearProfile() {
    name.value = '';
    email.value = '';
    dob.value = '';
    location.value = '';
    profileImageUrl.value = '';
    isAdmin.value = false;
    isPremium.value = false;
    planType.value = 'Free';
  }

  void _handleFirestoreError(dynamic e) {
    final errorStr = e.toString();
    if (errorStr.contains('NOT_FOUND') || errorStr.contains('database (default) does not exist') || errorStr.contains('database') && errorStr.contains('not exist')) {
      final context = Get.context;
      final isDark = context != null ? Theme.of(context).brightness == Brightness.dark : false;
      
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
                    color: Colors.amber.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber,
                    size: 54,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Database Setup Needed ⚠️',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Firestore database has not been initialized in your Firebase Console yet.\n\nPlease visit:\nhttps://console.cloud.google.com/datastore/setup?project=projectpulse-1faf3\nto create the default database.',
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
                      backgroundColor: Colors.amber[700],
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
  }

  Future<bool> recordSubscription({
    required String planType,
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return false;

      // 1. Record the subscription in the subscriptions collection
      await _firestore.collection('subscriptions').add({
        'userId': uid,
        'userEmail': email.value,
        'userName': name.value,
        'planType': planType,
        'amount': amount,
        'paymentMethod': paymentMethod,
        'status': 'success',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 2. Mark the user as premium in the users collection and save planType
      await _firestore.collection('users').doc(uid).set({
        'isPremium': true,
        'planType': planType,
      }, SetOptions(merge: true));

      isPremium.value = true;
      this.planType.value = planType; // Update observable so card reflects immediately
      return true;
    } catch (e) {
      debugPrint('Error recording subscription: $e');
      _handleFirestoreError(e);
      return false;
    }
  }
}
