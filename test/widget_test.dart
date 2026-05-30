import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:project_pulse/main.dart';
import 'package:project_pulse/controllers/project_controller.dart';
import 'package:project_pulse/controllers/notification_controller.dart';
import 'package:project_pulse/controllers/user_controller.dart';
import 'package:project_pulse/controllers/note_controller.dart';
import 'package:project_pulse/controllers/project_stats_controller.dart';
import 'package:project_pulse/models/project_model.dart';
import 'package:project_pulse/models/notification_model.dart';
import 'package:project_pulse/models/note_model.dart';
import 'package:project_pulse/models/milestone_model.dart';

void main() {
  setUpAll(() async {
    // Initialize Hive with a temporary path or sub-directory for testing
    Hive.init('test_hive');
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ProjectAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(MilestoneAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(AppNotificationAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(NoteAdapter());

    await Hive.openBox<Project>('projects');
    await Hive.openBox<AppNotification>('notifications');
    await Hive.openBox<Note>('notes');

    Get.put(NotificationController());
    Get.put(ProjectController());
    Get.put(UserController());
    Get.put(NoteController());
    Get.put(ProjectStatsController());
  });

  tearDownAll(() async {
    await Hive.close();
    Get.reset();
  });

  testWidgets('App should load', (WidgetTester tester) async {
    await tester.pumpWidget(const FreelanceFlowApp());
    expect(find.byType(FreelanceFlowApp), findsOneWidget);
  });
}
