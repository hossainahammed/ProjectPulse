import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  String id;
  String title;
  String message;
  DateTime timestamp;
  bool isRead;
  String type; // 'project_created', 'project_completed', 'milestone_deadline', 'project_deadline'

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    required this.type,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json, String documentId) {
    return AppNotification(
      id: documentId,
      title: json['title'] as String,
      message: json['message'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      isRead: json['isRead'] as bool? ?? false,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'type': type,
    };
  }
}
