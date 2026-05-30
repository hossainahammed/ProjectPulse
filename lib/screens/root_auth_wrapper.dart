import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class RootAuthWrapper extends StatelessWidget {
  const RootAuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Obx(() {
      final user = authController.firebaseUser.value;
      if (user == null || !user.emailVerified) {
        return const LoginScreen();
      } else {
        return const MainScreen();
      }
    });
  }
}
