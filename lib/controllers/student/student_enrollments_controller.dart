import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/model/event.dart';
import '../../data/model/event_enrollment.dart';
import '../auth_controller.dart';
import '../enrollment_controller.dart';

class StudentEnrollmentsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _authController = Get.find();
  final EnrollmentController _enrollmentController = Get.find();

  final RxList<EventEnrollment> enrollments = <EventEnrollment>[].obs;
  final RxList<Event> events = <Event>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isCancelling = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadEnrollments();
  }

  void _loadEnrollments() {
    final user = _authController.user.value;
    if (user == null) return;

    _firestore
        .collection('enrollments')
        .where('studentUid', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            // Get all enrollments
            List<EventEnrollment> allEnrollments = [];

            // Process each document using a for loop
            for (var doc in snapshot.docs) {
              final enrollment = EventEnrollment.fromJson(doc.data());
              allEnrollments.add(enrollment);
            }

            // Sort enrollments by enrolledAt descending using a for loop approach
            // This implements a simple insertion sort
            for (int i = 1; i < allEnrollments.length; i++) {
              EventEnrollment key = allEnrollments[i];
              int j = i - 1;

              while (j >= 0 &&
                  allEnrollments[j].enrolledAt.isBefore(key.enrolledAt)) {
                allEnrollments[j + 1] = allEnrollments[j];
                j = j - 1;
              }
              allEnrollments[j + 1] = key;
            }

            enrollments.value = allEnrollments;

            // Load corresponding events
            _loadEventsForEnrollments();
          }
          isLoading.value = false;
        });
  }

  void _loadEventsForEnrollments() async {
    try {
      final eventIds = enrollments.map((e) => e.eventId).toSet().toList();

      if (eventIds.isEmpty) {
        events.value = [];
        return;
      }

      // Get events from allEvents collection
      final eventsSnapshot = await _firestore
          .collection('allEvents')
          .where(FieldPath.documentId, whereIn: eventIds)
          .get();

      events.value = eventsSnapshot.docs
          .map((doc) => Event.fromJson(doc.data()))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load events: ${e.toString()}');
    }
  }

  Event? getEventForEnrollment(EventEnrollment enrollment) {
    return events.firstWhereOrNull(
      (event) => event.eventId == enrollment.eventId,
    );
  }

  Future<void> cancelEnrollment(EventEnrollment enrollment) async {
    try {
      isCancelling.value = true;

      // Check if payment was made - cannot cancel if payment is completed
      if (enrollment.paymentStatus == 'completed') {
        Get.snackbar(
          'Cannot Cancel',
          'Enrollment cannot be cancelled after payment is completed.',
          snackPosition: SnackPosition.BOTTOM,
        );
        isCancelling.value = false;
        return;
      }

      // Use the enrollment controller to handle cancellation
      await _enrollmentController.cancelEnrollment(enrollment.enrollmentId);

      Get.snackbar(
        'Cancelled',
        'Enrollment cancelled successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel enrollment: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isCancelling.value = false;
    }
  }

  void refreshEnrollments() {
    isLoading.value = true;
    _loadEnrollments();
  }
}
