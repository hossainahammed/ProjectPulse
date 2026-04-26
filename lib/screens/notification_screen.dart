import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/notification_controller.dart';
import '../models/notification_model.dart';

class NotificationScreen extends StatelessWidget {
  final NotificationController controller = Get.find<NotificationController>();

  NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () => _showClearDialog(),
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No notifications yet', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            return _buildNotificationCard(notification);
          },
        );
      }),
    );
  }

  void _showClearDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear All Notifications?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              controller.clearAll();
              Get.back();
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    IconData icon;
    Color color;

    switch (notification.type) {
      case 'project_created':
        icon = Icons.add_task;
        color = Colors.blue;
        break;
      case 'project_completed':
        icon = Icons.celebration;
        color = Colors.orange;
        break;
      case 'milestone_completed':
        icon = Icons.check_circle_outline;
        color = Colors.green;
        break;
      case 'milestone_deadline':
      case 'project_deadline':
        icon = Icons.warning_amber_rounded;
        color = Colors.red;
        break;
      default:
        icon = Icons.notifications;
        color = Get.theme.colorScheme.primary;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        onTap: () => controller.markAsRead(notification),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM dd, hh:mm a').format(notification.timestamp),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: !notification.isRead
            ? Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle))
            : null,
        isThreeLine: true,
      ),
    );
  }
}
