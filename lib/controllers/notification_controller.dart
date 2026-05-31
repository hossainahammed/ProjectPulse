import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/notification_model.dart';
import 'package:uuid/uuid.dart';

class NotificationController extends GetxController {
  late Box<AppNotification> _notificationBox;
  final RxList<AppNotification> notifications = <AppNotification>[].obs;

  // Settings
  final RxBool allEnabled = true.obs;
  final RxBool projectCompleteEnabled = true.obs;
  final RxBool deadlineAlertsEnabled = true.obs;
  final RxBool projectCreateEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    _notificationBox = Hive.box<AppNotification>('notifications');
    _loadNotifications();
  }

  void toggleAll(bool value) {
    allEnabled.value = value;
    projectCompleteEnabled.value = value;
    deadlineAlertsEnabled.value = value;
    projectCreateEnabled.value = value;
  }

  void _loadNotifications() {
    notifications.assignAll(_notificationBox.values.toList().reversed.toList());
  }

  Future<void> addNotification({
    required String title,
    required String message,
    required String type,
  }) async {
    final notification = AppNotification(
      id: const Uuid().v4(),
      title: title,
      message: message,
      timestamp: DateTime.now(),
      type: type,
    );
    await _notificationBox.add(notification);
    notifications.insert(0, notification);
  }

  Future<void> markAsRead(AppNotification notification) async {
    notification.isRead = true;
    await notification.save();
    notifications.refresh();
  }

  Future<void> deleteOne(AppNotification notification) async {
    await notification.delete(); // Hive HiveObject delete
    notifications.remove(notification);
  }

  Future<void> clearAll() async {
    await _notificationBox.clear();
    notifications.clear();
  }
}
