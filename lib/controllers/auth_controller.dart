import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'user_controller.dart';
import '../services/notification_service.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // clientId is required for Google Sign-In on Flutter Web.
  // Get it from: Firebase Console → Authentication → Sign-in method → Google → Web SDK configuration → Web client ID
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '57932149579-1ogiq4c45gjfe845vjvtbdbsr5tdkpss.apps.googleusercontent.com'
        : null,
  );

  // Observable Firebase User
  final Rxn<User> firebaseUser = Rxn<User>();

  // Loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Bind firebaseUser to authStateChanges stream
    firebaseUser.bindStream(_auth.authStateChanges());

    // Automatically load/clear profile in UserController when user session changes
    ever(firebaseUser, (User? user) {
      final uc = Get.find<UserController>();
      if (user != null) {
        // Seed email/name/photo instantly from FirebaseAuth (no Firestore wait)
        if (uc.email.value.isEmpty) uc.email.value = user.email ?? '';
        if (uc.name.value.isEmpty) uc.name.value = user.displayName ?? '';
        if (uc.profileImageUrl.value.isEmpty)
          uc.profileImageUrl.value = user.photoURL ?? '';
        // Then fetch full profile from Firestore
        uc.fetchUserProfile(user.uid);
        // Register device for push notifications
        NotificationService.registerCurrentDeviceToken();
      } else {
        uc.clearProfile();
      }
    });
  }

  // Get current user email
  String get userEmail => firebaseUser.value?.email ?? '';

  // Sign Up with Email and Password
  Future<bool> signUp(String name, String email, String password) async {
    try {
      isLoading.value = true;
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Ensure profile document is initialized in Firestore
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(name);
        await Get.find<UserController>().ensureProfileExists(
          userCredential.user!.uid,
          name: name,
          email: userCredential.user!.email ?? '',
          profileImageUrl: '',
        );
        // Send email verification link
        await userCredential.user!.sendEmailVerification();
      }

      // Sign out immediately so they are not auto-logged in
      await _auth.signOut();

      isLoading.value = false;
      return true;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      String errorMsg = e.message ?? 'An error occurred during registration.';
      if (e.code == 'weak-password') {
        errorMsg = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMsg = 'An account already exists for this email.';
      } else if (e.code == 'invalid-email') {
        errorMsg = 'The email address is not valid.';
      } else if (e.code == 'operation-not-allowed') {
        errorMsg =
            'Email/Password sign-in is disabled in your Firebase console. Please go to your Firebase Console -> Authentication -> Sign-in method, and enable "Email/Password".';
      }
      _showErrorDialog('Registration Failed', errorMsg);
      return false;
    } catch (e) {
      isLoading.value = false;
      //_showErrorDialog('Error', e.toString());
      _showErrorDialog('Error', _getReadableError(e));
      return false;
    }
  }

  // Sign In with Email and Password
  Future<bool> signIn(String email, String password) async {
    try {
      isLoading.value = true;
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      // Verify email status
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        // Trigger verification email resend
        await userCredential.user!.sendEmailVerification();
        await _auth.signOut();
        isLoading.value = false;
        _showErrorDialog('Email Not Verified',
            'A new verification link has been sent to $email. Please check your inbox (and spam folder) and verify your email before logging in.');
        return false;
      }

      isLoading.value = false;
      return true;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;

      String errorMsg = 'Login failed. Please try again.';

      if (e.code == 'user-not-found') {
        errorMsg = 'No account found with this email.';
      } else if (e.code == 'wrong-password') {
        errorMsg = 'Incorrect password.';
      } else if (e.code == 'invalid-email') {
        errorMsg = 'Please enter a valid email address.';
      } else if (e.code == 'user-disabled') {
        errorMsg = 'This account has been disabled.';
      } else if (e.code == 'network-request-failed') {
        errorMsg = 'No internet connection. Please check your network.';
      } else if (e.code == 'too-many-requests') {
        errorMsg = 'Too many login attempts. Try again later.';
      } else if (e.code == 'invalid-credential') {
        errorMsg = 'Email or password is incorrect.';
      }

      _showErrorDialog('Login Failed', errorMsg);
      return false;
    }
    // } on FirebaseAuthException catch (e) {
    //   isLoading.value = false;
    //   String errorMsg = e.message ?? 'Invalid email or password.';
    //   if (e.code == 'user-not-found') {
    //     errorMsg = 'No user found for this email.';
    //   } else if (e.code == 'wrong-password') {
    //     errorMsg = 'Incorrect password provided.';
    //   } else if (e.code == 'invalid-email') {
    //     errorMsg = 'The email address is not valid.';
    //   } else if (e.code == 'user-disabled') {
    //     errorMsg = 'This user account has been disabled.';
    //   } else if (e.code == 'operation-not-allowed') {
    //     errorMsg = 'Email/Password sign-in is disabled in your Firebase console. Please go to your Firebase Console -> Authentication -> Sign-in method, and enable "Email/Password".';
    //   }
    //   _showErrorDialog('Login Failed', errorMsg);
    //   return false;
    // } catch (e) {
    //   isLoading.value = false;
    //   //_showErrorDialog('Error', e.toString());
    //   _showErrorDialog('Error', _getReadableError(e));
    //   return false;
    // }
  }

  // Google Sign-In Flow
  Future<bool> signInWithGoogle() async {
    try {
      isLoading.value = true;

      // Trigger sign-in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        isLoading.value = false;
        return false;
      }

      // Obtain authentication tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Authenticate with Firebase
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Ensure user profile document exists in Cloud Firestore
      if (userCredential.user != null) {
        await Get.find<UserController>().ensureProfileExists(
          userCredential.user!.uid,
          name: userCredential.user!.displayName ?? '',
          email: userCredential.user!.email ?? '',
          profileImageUrl: userCredential.user!.photoURL ?? '',
        );
      }

      isLoading.value = false;
      return true;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;

      String message = 'Google sign-in failed.';

      if (e.code == 'network-request-failed') {
        message = 'Please check your internet connection.';
      } else if (e.code == 'account-exists-with-different-credential') {
        message = 'An account already exists with another sign-in method.';
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid Google credentials.';
      } else if (e.code == 'too-many-requests') {
        message = 'Too many attempts. Please try again later.';
      } else if (e.code == 'user-disabled') {
        message = 'This account has been disabled.';
      }

      _showErrorDialog('Google Sign-In Failed', message);
      return false;
    } catch (e) {
      isLoading.value = false;

      _showErrorDialog('Error', _getReadableError(e));
      return false;
    }
    // } on FirebaseAuthException catch (e) {
    //   isLoading.value = false;
    //   _showErrorDialog('Google Sign-In Failed', e.message ?? 'An authentication error occurred.');
    //   return false;
    // } catch (e) {
    //   isLoading.value = false;
    //  // _showErrorDialog('Error', e.toString());
    //   _showErrorDialog('Error', _getReadableError(e));
    //   return false;
    // }
  }

  // Check if email has been verified
  Future<void> checkEmailVerified() async {
    try {
      isLoading.value = true;
      final User? user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        // Update reactive user observable
        firebaseUser.value = _auth.currentUser;

        if (firebaseUser.value?.emailVerified ?? false) {
          Get.snackbar(
            'Email Verified! 🎉',
            'Your email has been verified successfully. Welcome to ProjectPulse!',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green[600],
            colorText: Colors.white,
          );
        } else {
          _showErrorDialog('Not Verified Yet',
              'We couldn\'t verify your email yet. Please make sure you clicked the link in the verification email sent to ${user.email}, then click "Check Status" again.');
        }
      }
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      _showErrorDialog('Error Checking Verification', e.toString());
    }
  }

  // Resend Verification Email
  Future<bool> resendVerificationEmail() async {
    try {
      isLoading.value = true;
      final User? user = _auth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        isLoading.value = false;

        _showSuccessDialog('Verification Sent! ✉️',
            'A new verification link has been sent to:\n${user.email}\n\nPlease check your inbox (and spam folder) and click the link to verify.');
        return true;
      }
      isLoading.value = false;
      return false;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      _showErrorDialog(
          'Resend Failed', e.message ?? 'Failed to send verification email.');
      return false;
    } catch (e) {
      isLoading.value = false;
      // _showErrorDialog('Error', e.toString());
      _showErrorDialog('Error', _getReadableError(e));
      return false;
    }
  }

  // Send Password Reset Email
  Future<bool> resetPassword(String email) async {
    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: email);
      isLoading.value = false;
      return true;
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      String errorMsg = e.message ?? 'Failed to send password reset email.';
      if (e.code == 'user-not-found') {
        errorMsg = 'No account found with this email.';
      } else if (e.code == 'invalid-email') {
        errorMsg = 'The email address is not valid.';
      }
      _showErrorDialog('Reset Failed', errorMsg);
      return false;
    } catch (e) {
      isLoading.value = false;
      // _showErrorDialog('Error', e.toString());
      _showErrorDialog('Error', _getReadableError(e));
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await NotificationService.removeTokenFromDatabase();
      await _auth.signOut();
    } catch (e) {
      _showErrorDialog('Sign Out Failed', e.toString());
    }
  }

  // Helper method to show error dialogs
  void _showErrorDialog(String title, String message) {
    final context = Get.context;
    if (context == null) return;
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
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
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

  // Helper method to show success dialogs
  void _showSuccessDialog(String title, String message) {
    final context = Get.context;
    if (context == null) return;
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
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
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

  String _getReadableError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Network errors
    if (errorString.contains('network_error') ||
        errorString.contains('network error') ||
        errorString.contains('apiexception: 7')) {
      return 'No internet connection. Please check your network and try again.';
    }

    // Google Sign-In cancelled
    if (errorString.contains('sign_in_canceled') ||
        errorString.contains('sign in canceled')) {
      return 'Google sign-in was cancelled.';
    }

    // Firebase invalid credential
    if (errorString.contains('invalid-credential')) {
      return 'Authentication failed. Please try again.';
    }

    // Too many requests
    if (errorString.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    }

    // User disabled
    if (errorString.contains('user-disabled')) {
      return 'This account has been disabled.';
    }

    // Default fallback
    return 'Something went wrong. Please try again.';
  }
}
