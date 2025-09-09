import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:event_board/data/services/network_service.dart';

import '../auth_controller.dart';

class StudentNotification {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;

  StudentNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
  });

  factory StudentNotification.fromJson(Map<String, dynamic> json) {
    return StudentNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      isRead: json['isRead'] ?? false,
    );
  }
}

class StudentNotificationsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NetworkService _networkService = Get.find();

  final RxList<StudentNotification> notifications = <StudentNotification>[].obs;
  final RxBool isLoading = true.obs;

  DocumentSnapshot? _lastNotificationDoc;
  static const int _pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
  }

  Future<void> _loadNotifications({bool refresh = false}) async {
    try {
      if (!await _networkService.isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        if (refresh) {
          isLoading.value = false;
        }
        return;
      }
      if (refresh) {
        isLoading.value = true;
        _lastNotificationDoc = null;
        notifications.clear();
      }

      final user = Get.find<AuthController>().user.value;
      if (user == null) return;

      // In a real implementation, you'd query user-specific notifications
      // For demo, we'll create sample notifications
      List<StudentNotification> sampleNotifications = [
        StudentNotification(
          id: '1',
          title: 'Event Reminder',
          body: 'Your event "Flutter Workshop" starts in 1 hour',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          isRead: false,
        ),
        StudentNotification(
          id: '2',
          title: 'New Event',
          body: 'A new event "AI Conference" has been added',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          isRead: true,
        ),
        StudentNotification(
          id: '3',
          title: 'Enrollment Confirmed',
          body: 'Your enrollment for "Tech Talk" has been confirmed',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          isRead: true,
        ),
      ];

      notifications.value = sampleNotifications;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load notifications');
    } finally {
      if (refresh) {
        isLoading.value = false;
      }
    }
  }

  Future<void> refreshNotifications() async {
    await _loadNotifications(refresh: true);
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      // Update notification status
      for (int i = 0; i < notifications.length; i++) {
        if (notifications[i].id == notificationId) {
          notifications[i] = StudentNotification(
            id: notifications[i].id,
            title: notifications[i].title,
            body: notifications[i].body,
            createdAt: notifications[i].createdAt,
            isRead: true,
          );
          break;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark as read');
    }
  }
}
