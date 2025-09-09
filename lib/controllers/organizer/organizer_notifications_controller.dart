import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrganizerNotificationsController extends GetxController {
  final RxList<AppNotification> notifications = <AppNotification>[
    AppNotification(
      id: '1',
      title: 'New Event Enrollment',
      body: 'A new student has enrolled in your event: Flutter Forward.',
      receivedAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    AppNotification(
      id: '2',
      title: 'Event Approved',
      body: 'Your event \'Tech Talk: The Future of AI\' has been approved.',
      receivedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AppNotification(
      id: '3',
      title: 'Merchandise Sold',
      body: 'An item \'University Hoodie\' has been sold.',
      receivedAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    AppNotification(
      id: '4',
      title: 'Payout Processed',
      body: 'Your weekly payout of ₹12,500 has been processed.',
      receivedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ].obs;

  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < notifications.length; i++) {
      if (!notifications[i].isRead) {
        notifications[i] = notifications[i].copyWith(isRead: true);
      }
    }
  }

  void deleteNotification(String id) {
    notifications.removeWhere((n) => n.id == id);
  }
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime receivedAt;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.isRead = false,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      receivedAt: receivedAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
