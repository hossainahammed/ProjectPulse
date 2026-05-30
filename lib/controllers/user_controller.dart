import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  final RxBool isPremium = false.obs;
  // Observable theme flag — toggled when user switches theme so Obx rebuilds
  final RxBool isDarkMode = false.obs;

  // Reactive user profile properties
  final RxString name = ''.obs;
  final RxString email = ''.obs;
  final RxString dob = ''.obs;
  final RxString location = ''.obs;
  final RxString profileImageUrl = ''.obs;
  final RxBool isLoadingProfile = false.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
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

  void togglePremium() {
    isPremium.value = !isPremium.value;
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

        if (fsName.isNotEmpty) name.value = fsName;
        if (fsEmail.isNotEmpty) email.value = fsEmail;
        if (fsDob.isNotEmpty) dob.value = fsDob;
        if (fsLocation.isNotEmpty) location.value = fsLocation;
        if (fsImageUrl.isNotEmpty) profileImageUrl.value = fsImageUrl;
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
      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'dob': dob,
        'location': location,
      });

      this.name.value = name;
      this.dob.value = dob;
      this.location.value = location;
      
      isLoadingProfile.value = false;
      return true;
    } catch (e) {
      isLoadingProfile.value = false;
      debugPrint('Error updating user profile: $e');
      return false;
    }
  }

  // Upload profile photo to Firebase Storage and update database
  Future<bool> uploadProfileImage(File imageFile) async {
    try {
      final String? uid = _auth.currentUser?.uid;
      if (uid == null) return false;

      isLoadingProfile.value = true;
      
      // Upload task to Firebase Storage
      final Reference ref = _storage.ref().child('profile_images').child('$uid.jpg');
      final UploadTask uploadTask = ref.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;
      
      // Retrieve download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Update Firestore user document
      await _firestore.collection('users').doc(uid).update({
        'profileImageUrl': downloadUrl,
      });

      profileImageUrl.value = downloadUrl;
      isLoadingProfile.value = false;
      return true;
    } catch (e) {
      isLoadingProfile.value = false;
      debugPrint('Error uploading profile image: $e');
      return false;
    }
  }

  // Reset observable state on sign out
  void clearProfile() {
    name.value = '';
    email.value = '';
    dob.value = '';
    location.value = '';
    profileImageUrl.value = '';
  }
}
