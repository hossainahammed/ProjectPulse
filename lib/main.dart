import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
// import 'models/project_model.dart';
// import 'models/milestone_model.dart';
// import 'models/notification_model.dart';
// import 'models/note_model.dart';
import 'controllers/project_controller.dart';
import 'controllers/notification_controller.dart';
import 'controllers/user_controller.dart';
import 'controllers/note_controller.dart';
import 'controllers/project_stats_controller.dart';
import 'services/notification_service.dart';
import 'services/analytics_service.dart';

import 'controllers/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'screens/root_auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ── Firebase Crashlytics ────────────────────────────────────────────────
  // Crashlytics is only supported on Android and iOS (not Web/Desktop)
  if (!kIsWeb) {
    final crashlytics = FirebaseCrashlytics.instance;

    // Pass Flutter framework errors to Crashlytics
    FlutterError.onError = crashlytics.recordFlutterFatalError;

    // Enable/disable collection based on build mode
    await crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
  }

  // ── Firebase Analytics ─────────────────────────────────────────────────
  // Analytics is supported on Android, iOS, and Web
  if (kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  }

  // Enable Firestore offline persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  // Initialize Notifications (mobile only)
  if (!kIsWeb) {
    await NotificationService.init();
  }

  // Inject Controllers
  Get.put(NotificationController());
  Get.put(ProjectController());
  Get.put(UserController());
  Get.put(NoteController());
  Get.put(ProjectStatsController());
  Get.put(AuthController());

  // ── Run app inside error zone ──────────────────────────────────────────
  // Catches async/non-Flutter errors and reports them to Crashlytics
  runZonedGuarded(
    () => runApp(
      DevicePreview(
        // enabled: !kReleaseMode,
        enabled: false,
        builder: (context) => FreelanceFlowApp(seenOnboarding: seenOnboarding),
      ),
    ),
    (error, stack) {
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      }
      debugPrint('[Crashlytics] Uncaught async error: $error');
    },
  );
}

class FreelanceFlowApp extends StatelessWidget {
  final bool seenOnboarding;
  const FreelanceFlowApp({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // DevicePreview: only apply its builder in non-release mode and non-web
      useInheritedMediaQuery: !kIsWeb,
      locale: kIsWeb ? null : DevicePreview.locale(context),
      builder: kIsWeb
          ? (context, child) => _WebAppBuilder(child: child!)
          : DevicePreview.appBuilder,
      title: 'ProjectPulse',
      debugShowCheckedModeBanner: false,
      scrollBehavior: kIsWeb ? _WebScrollBehavior() : null,
      // ── Analytics Screen Tracking ──────────────────────────────────────
      navigatorObservers: [
        if (!kIsWeb ||
            defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)
          AnalyticsService.instance.observer,
      ],
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
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF1E293B),
          elevation: 0,
          scrolledUnderElevation: 0,
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
          seedColor: const Color(0xFFD946EF),
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
          scrolledUnderElevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E293B),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      themeMode: ThemeMode.system,
      home: SplashScreen(seenOnboarding: seenOnboarding),
    );
  }
}

///////////RElease version 1

/// Applies a thin scrollbar and mouse-drag scroll support for web.
class _WebScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
  };

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Use a thin, styled scrollbar on web
    return RawScrollbar(
      controller: details.controller,
      thumbColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
      radius: const Radius.circular(8),
      thickness: 4,
      child: child,
    );
  }
}

/// On web, just pass the child through with no DevicePreview wrapping.
class _WebAppBuilder extends StatelessWidget {
  final Widget child;
  const _WebAppBuilder({required this.child});

  @override
  Widget build(BuildContext context) => child;
}
