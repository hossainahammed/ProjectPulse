import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'models/project_model.dart';
import 'models/milestone_model.dart';
import 'models/notification_model.dart';
import 'models/note_model.dart';
import 'controllers/project_controller.dart';
import 'controllers/notification_controller.dart';
import 'controllers/user_controller.dart';
import 'controllers/note_controller.dart';
import 'controllers/project_stats_controller.dart';
import 'services/notification_service.dart';

import 'controllers/auth_controller.dart';
import 'screens/root_auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Hive
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(ProjectAdapter());
  Hive.registerAdapter(MilestoneAdapter());
  Hive.registerAdapter(AppNotificationAdapter());
  Hive.registerAdapter(NoteAdapter());

  // Open Boxes
  await Hive.openBox<Project>('projects');
  await Hive.openBox<AppNotification>('notifications');
  await Hive.openBox<Note>('notes');

  // Initialize Notifications
  await NotificationService.init();

  // Inject Controllers
  Get.put(NotificationController());
  Get.put(ProjectController());
  Get.put(UserController());
  Get.put(NoteController());
  Get.put(ProjectStatsController());
  Get.put(AuthController());

  runApp(
    DevicePreview(
      // enabled: !kReleaseMode,
      enabled: false,
      builder: (context) => const FreelanceFlowApp(),
    ),
  );
}

class FreelanceFlowApp extends StatelessWidget {
  const FreelanceFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'ProjectPulse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.light,
          primary: const Color(0xFF4F46E5),
          secondary: const Color(0xFF7C3AED),
        ),
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8FAFC),
          foregroundColor: Color(0xFF1E293B),
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD946EF), // Fuchsia/Pink accent from image
          brightness: Brightness.dark,
          primary: const Color(0xFFD946EF),
          secondary: const Color(0xFF8B5CF6),
          surface: const Color(0xFF1E293B),
        ),
        scaffoldBackgroundColor: const Color(0xFF020617),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E293B),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const RootAuthWrapper(),
    );
  }
}
