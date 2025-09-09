import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../data/model/enrollment.dart';
import '../../data/model/event.dart';
import '../auth_controller.dart';

class EventDetailController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late Event event;
  Rx<Enrollment?> enrollment = Rx<Enrollment?>(null);
  RxBool isLoading = false.obs;
  RxBool isEnrolled = false.obs;
  RxString enrollmentStatus = ''.obs;

  @override
  void onInit() {
    super.onInit();
    event = Get.arguments as Event;
    _checkEnrollmentStatus();
  }

  Future<void> _checkEnrollmentStatus() async {
    try {
      final user = Get.find<AuthController>().user.value;
      if (user == null) return;

      QuerySnapshot snapshot = await _firestore
          .collection('organizations')
          .doc(
            event.createdByUid,
          ) // This would need to be adjusted based on actual structure
          .collection('events')
          .doc(event.eventId)
          .collection('enrollments')
          .where('studentUid', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        enrollment.value = Enrollment.fromJson(
          snapshot.docs.first.data() as Map<String, dynamic>,
        );
        isEnrolled.value = true;
        enrollmentStatus.value = enrollment.value!.status;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to check enrollment status');
    }
  }

  Future<void> enrollInEvent() async {
    try {
      isLoading.value = true;
      final user = Get.find<AuthController>().user.value;
      if (user == null) return;

      // Check if already enrolled
      if (isEnrolled.value) {
        Get.snackbar('Info', 'You are already enrolled in this event');
        return;
      }

      // Check capacity
      if (event.enrolledCount >= event.capacity) {
        Get.snackbar('Error', 'Event is full');
        return;
      }

      // Create enrollment
      final enrollmentId = _firestore.collection('temp').doc().id;
      final newEnrollment = Enrollment(
        enrollId: enrollmentId,
        studentUid: user.uid,
        registeredAt: DateTime.now(),
        status: 'registered',
        pricePaid: event.price,
      );

      // Simulate payment flow for paid events
      if (event.price > 0) {
        // In a real app, this would integrate with a payment gateway
        await Future.delayed(const Duration(seconds: 2));
        // Simulate successful payment
      }

      // Save enrollment
      await _firestore
          .collection('organizations')
          .doc(event.createdByUid) // Adjust path as needed
          .collection('events')
          .doc(event.eventId)
          .collection('enrollments')
          .doc(enrollmentId)
          .set(newEnrollment.toJson());

      enrollment.value = newEnrollment;
      isEnrolled.value = true;
      enrollmentStatus.value = 'registered';

      Get.snackbar('Success', 'Successfully enrolled in the event!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to enroll: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelEnrollment() async {
    try {
      isLoading.value = true;

      if (enrollment.value == null) return;

      await _firestore
          .collection('organizations')
          .doc(event.createdByUid) // Adjust path as needed
          .collection('events')
          .doc(event.eventId)
          .collection('enrollments')
          .doc(enrollment.value!.enrollId)
          .delete();

      enrollment.value = null;
      isEnrolled.value = false;
      enrollmentStatus.value = '';

      Get.snackbar('Success', 'Enrollment cancelled');
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel enrollment');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> generateQRCode() async {
    try {
      if (enrollment.value == null) return;

      // Generate QR code data
      final qrData = {
        'orgType': 'clubs', // This would come from event data
        'orgId': event.createdByUid,
        'eventId': event.eventId,
        'enrollId': enrollment.value!.enrollId,
      };

      // Show QR dialog
      Get.defaultDialog(
        title: 'Check-in QR Code',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: qrData.toString(),
              version: QrVersions.auto,
              size: 200.0,
            ),
            const SizedBox(height: 16),
            const Text(
              'Show this QR code at the event entrance for check-in',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate QR code');
    }
  }
}
