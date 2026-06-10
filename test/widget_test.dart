// import 'dart:io';
// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
//import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:project_pulse/main.dart';
import 'package:project_pulse/controllers/auth_controller.dart';
import 'package:project_pulse/controllers/project_controller.dart';
import 'package:project_pulse/controllers/notification_controller.dart';
// import 'package:project_pulse/controllers/user_controller.dart';
import 'package:project_pulse/controllers/note_controller.dart';
import 'package:project_pulse/controllers/project_stats_controller.dart';
// import 'package:project_pulse/models/project_model.dart';
// import 'package:project_pulse/models/notification_model.dart';
// import 'package:project_pulse/models/note_model.dart';
// import 'package:project_pulse/models/milestone_model.dart';

void main() {
  setUpAll(() async {
    // Initialize Hive with a temporary path or sub-directory for testing
    // Hive.init('test_hive');
    // if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ProjectAdapter());
    // if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(MilestoneAdapter());
    // if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(AppNotificationAdapter());
    // if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(NoteAdapter());
    //
    // await Hive.openBox<Project>('projects');
    // await Hive.openBox<AppNotification>('notifications');
    // await Hive.openBox<Note>('notes');

    Get.put(NotificationController());
    Get.put(ProjectController());
    // Use mock so no Firebase calls are made during testing
    // Get.put<UserController>(MockUserController());
    Get.put(NoteController());
    Get.put(ProjectStatsController());
    Get.put<AuthController>(MockAuthController());
  });

  // tearDownAll(() async {
  //   await Hive.close();
  //   Get.reset();
  // });

  testWidgets('App should load', (WidgetTester tester) async {
    await tester.pumpWidget(const FreelanceFlowApp());
    expect(find.byType(FreelanceFlowApp), findsOneWidget);
  });
}

// ---------------------------------------------------------------------------
// Mock controllers — replicate the public API without touching Firebase
// ---------------------------------------------------------------------------

// class MockUserController extends GetxController implements UserController {
//   @override
//   final RxBool isPremium = false.obs;
//
//   @override
//   final RxBool isAdmin = false.obs;
//
//   @override
//   final RxBool isDarkMode = false.obs;
//
//   @override
//   final RxString name = ''.obs;
//
//   @override
//   final RxString email = ''.obs;
//
//   @override
//   final RxString dob = ''.obs;
//
//   @override
//   final RxString location = ''.obs;
//
//   @override
//   final RxString profileImageUrl = ''.obs;
//
//   @override
//   final RxBool isLoadingProfile = false.obs;
//
//   @override
//   void togglePremium() {}
//
//   @override
//   void setDarkMode(bool value) {
//     isDarkMode.value = value;
//     Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
//   }
//
//   @override
//   Future<void> fetchUserProfile(String uid) async {}
//
//   @override
//   Future<void> ensureProfileExists(
//     String uid, {
//     required String name,
//     required String email,
//     required String profileImageUrl,
//   }) async {}
//
//   @override
//   Future<bool> updateUserProfile({
//     required String name,
//     required String dob,
//     required String location,
//   }) async =>
//       true;
//
//   @override
//   Future<bool> uploadProfileImage(File imageFile) async => true;
//
//   @override
//   ImageProvider getProfileImageProvider(String imageUrl) {
//     return const AssetImage('assets/images/user_profile.png');
//   }
//
//   @override
//   void clearProfile() {
//     name.value = '';
//     email.value = '';
//     dob.value = '';
//     location.value = '';
//     profileImageUrl.value = '';
//   }
//
//   @override
//   Future<bool> recordSubscription({
//     required String planType,
//     required double amount,
//     required String paymentMethod,
//   }) async =>
//       true;
// }

class MockAuthController extends GetxController implements AuthController {
  @override
  final Rxn<fb.User> firebaseUser = Rxn<fb.User>(null);

  @override
  final RxBool isLoading = false.obs;

  @override
  String get userEmail => 'test@example.com';

  @override
  Future<bool> signIn(String email, String password) async => true;

  @override
  Future<bool> signUp(String name, String email, String password) async => true;

  @override
  Future<bool> resetPassword(String email) async => true;

  @override
  Future<void> checkEmailVerified() async {}

  @override
  Future<bool> resendVerificationEmail() async => true;

  @override
  Future<bool> signInWithGoogle() async => true;

  @override
  Future<void> signOut() async {}
}
