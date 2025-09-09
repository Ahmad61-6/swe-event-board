import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../controllers/organizer/organizer_notifications_controller.dart';

class OrganizerNotificationsView extends StatelessWidget {
  const OrganizerNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final OrganizerNotificationsController controller = Get.put(
      OrganizerNotificationsController(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: controller.markAllAsRead,
            child: const Text('Mark all as read'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                const Text(
                  'You have no notifications',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            return Obx(
              () => Container(
                color: notification.isRead
                    ? Colors.transparent
                    : Theme.of(context).primaryColor.withOpacity(0.05),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: notification.isRead
                        ? Colors.grey
                        : Theme.of(context).primaryColor,
                    child: const Icon(Icons.notifications, color: Colors.white),
                  ),
                  title: Text(
                    notification.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${notification.body}\n${timeago.format(notification.receivedAt)}',
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'read') {
                        controller.markAsRead(notification.id);
                      } else if (value == 'delete') {
                        controller.deleteNotification(notification.id);
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                          if (!notification.isRead)
                            const PopupMenuItem<String>(
                              value: 'read',
                              child: Text('Mark as read'),
                            ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
