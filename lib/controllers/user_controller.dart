import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  final RxBool isPremium = false.obs;
  // Observable theme flag — toggled when user switches theme so Obx rebuilds
  final RxBool isDarkMode = false.obs;

  void togglePremium() {
    isPremium.value = !isPremium.value;
  }

  /// Call this whenever the theme mode changes (in ProfileScreen's toggle)
  void setDarkMode(bool value) {
    isDarkMode.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }
}
