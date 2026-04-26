import 'package:hive/hive.dart';

part 'notification_model.g.dart';

@HiveType(typeId: 2)
class AppNotification extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String message;

  @HiveField(3)
  DateTime timestamp;

  @HiveField(4)
  bool isRead;

  @HiveField(5)
  String type; // 'project_created', 'project_completed', 'milestone_deadline', 'project_deadline'

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    required this.type,
  });
}
