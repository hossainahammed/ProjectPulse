import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/notification_controller.dart';
import '../controllers/user_controller.dart';
import '../models/notification_model.dart';

class NotificationScreen extends StatelessWidget {
  final NotificationController controller = Get.find<NotificationController>();

  NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Get.find<UserController>().isDarkMode.value;
    final bgColor = isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        centerTitle: true,
        actions: [
          Obx(() => controller.notifications.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  icon: Icon(Icons.delete_sweep_outlined, color: Colors.red[400]),
                  onPressed: () => _showClearDialog(),
                  tooltip: 'Clear All',
                )),
        ],
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.notifications_off_outlined, size: 56, color: Colors.grey[400]),
                ),
                const SizedBox(height: 16),
                Text(
                  'No notifications yet',
                  style: TextStyle(color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            return _buildDismissibleCard(context, notification, isDark, textColor);
          },
        );
      }),
    );
  }

  Widget _buildDismissibleCard(BuildContext context, AppNotification notification, bool isDark, Color textColor) {
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
        color = Theme.of(context).colorScheme.primary;
    }

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => controller.deleteOne(notification),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark
              ? (notification.isRead ? const Color(0xFF1E293B) : const Color(0xFF1E293B))
              : (notification.isRead ? Colors.white : const Color(0xFFFAF5FF)),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: notification.isRead
                ? (isDark ? Colors.white10 : Colors.grey.shade200)
                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          onTap: () => controller.markAsRead(notification),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
              color: textColor,
              fontSize: 14,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.message,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                DateFormat('MMM dd, hh:mm a').format(notification.timestamp),
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
          trailing: !notification.isRead
              ? Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
          isThreeLine: true,
        ),
      ),
    );
  }

  void _showClearDialog() {
    final isDark = Get.find<UserController>().isDarkMode.value;
    Get.dialog(
      Dialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_sweep_rounded, color: Colors.red, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                'Clear All Notifications?',
                style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This action cannot be undone.',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: BorderSide(color: isDark ? Colors.white24 : Colors.grey.shade300),
                      ),
                      child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        controller.clearAll();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text('Clear All', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
