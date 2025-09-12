import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_board/controllers/auth_controller.dart';
import 'package:event_board/data/services/network_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/model/event.dart';
import '../data/model/event_enrollment.dart';
import '../data/model/organization.dart';

class EnrollmentController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NetworkService _networkService = Get.find();
  final AuthController _authController = Get.find();

  final RxList<EventEnrollment> studentEnrollments = <EventEnrollment>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isEnrolling = false.obs;
  final RxBool isCancelling = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadStudentEnrollments();
  }

  Future<void> _loadStudentEnrollments() async {
    try {
      isLoading.value = true;
      final user = _authController.user.value;
      if (user == null) return;

      // Get all enrollments and filter/sort locally
      _firestore
          .collection('enrollments')
          .where('studentUid', isEqualTo: user.uid)
          .snapshots()
          .listen((snapshot) {
            if (snapshot.docs.isNotEmpty) {
              // Sort locally by enrolledAt descending
              List<EventEnrollment> allEnrollments = snapshot.docs
                  .map((doc) => EventEnrollment.fromJson(doc.data()))
                  .toList();

              allEnrollments.sort(
                (a, b) => b.enrolledAt.compareTo(a.enrolledAt),
              );

              studentEnrollments.value = allEnrollments;
            }
            isLoading.value = false;
          });
    } catch (e) {
      Get.snackbar('Error', 'Failed to load enrollments: ${e.toString()}');
      isLoading.value = false;
    }
  }

  // Helper method to get organization ID for an event
  Future<String?> _getOrganizationIdForEvent(String createdByUid) async {
    try {
      final orgSnapshot = await _firestore
          .collection('organizations')
          .where('ownerUid', isEqualTo: createdByUid)
          .limit(1)
          .get();

      if (orgSnapshot.docs.isNotEmpty) {
        final org = Organization.fromJson(
          orgSnapshot.docs.first.data() as Map<String, dynamic>,
        );
        return org.orgId;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> enrollToEvent(Event event, {double? amountPaid}) async {
    try {
      isEnrolling.value = true;

      if (!await _networkService.isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        isEnrolling.value = false;
        return false;
      }

      final user = _authController.user.value;
      if (user == null) {
        isEnrolling.value = false;
        return false;
      }

      // Check if event is already full
      if (event.enrolledCount >= event.capacity) {
        Get.snackbar('Event Full', 'This event has reached its capacity.');
        isEnrolling.value = false;
        return false;
      }

      // Check if student is already enrolled
      final existingEnrollment = await _firestore
          .collection('enrollments')
          .where('eventId', isEqualTo: event.eventId)
          .where('studentUid', isEqualTo: user.uid)
          .get();

      if (existingEnrollment.docs.isNotEmpty) {
        Get.snackbar(
          'Already Enrolled',
          'You are already enrolled in this event.',
        );
        isEnrolling.value = false;
        return false;
      }

      // Get the organization ID for this event
      final orgId = await _getOrganizationIdForEvent(event.createdByUid);
      if (orgId == null) {
        Get.snackbar('Error', 'Could not find organization for this event.');
        isEnrolling.value = false;
        return false;
      }

      // Validate payment for paid events
      if (event.price > 0) {
        if (amountPaid == null || amountPaid < event.price) {
          Get.snackbar(
            'Payment Required',
            'This event requires payment of BDT ${event.price}. '
                'Please complete the payment to enroll.',
          );
          isEnrolling.value = false;
          return false;
        }
      }

      final enrollmentId = _firestore.collection('enrollments').doc().id;

      // Create enrollment record
      final enrollment = EventEnrollment(
        enrollmentId: enrollmentId,
        eventId: event.eventId,
        studentUid: user.uid,
        organizerUid: event.createdByUid,
        orgId: orgId, // Use the actual organization ID
        eventTitle: event.title,
        amountPaid: amountPaid ?? event.price,
        paymentStatus: event.price > 0
            ? (amountPaid != null ? 'completed' : 'pending')
            : 'completed',
        enrollmentStatus: 'registered',
        enrolledAt: DateTime.now(),
        paymentCompletedAt: event.price > 0 && amountPaid != null
            ? DateTime.now()
            : null,
      );

      final batch = _firestore.batch();

      // Add to enrollments collection
      final enrollmentRef = _firestore
          .collection('enrollments')
          .doc(enrollmentId);
      batch.set(enrollmentRef, enrollment.toJson());

      // Add to student's enrollments subcollection
      final studentEnrollmentRef = _firestore
          .collection('students')
          .doc(user.uid)
          .collection('enrollments')
          .doc(enrollmentId);
      batch.set(studentEnrollmentRef, enrollment.toJson());

      // Add to organization's enrollments subcollection (using correct orgId)
      final orgEnrollmentRef = _firestore
          .collection('organizations')
          .doc(orgId) // Use orgId instead of organizer UID
          .collection('events')
          .doc(event.eventId)
          .collection('enrollments')
          .doc(enrollmentId);
      batch.set(orgEnrollmentRef, enrollment.toJson());

      // Update event enrollment count in organization's events
      final orgEventRef = _firestore
          .collection('organizations')
          .doc(orgId) // Use orgId instead of organizer UID
          .collection('events')
          .doc(event.eventId);
      batch.update(orgEventRef, {'enrolledCount': FieldValue.increment(1)});

      // Update allEvents collection
      final allEventRef = _firestore.collection('allEvents').doc(event.eventId);
      batch.update(allEventRef, {'enrolledCount': FieldValue.increment(1)});

      await batch.commit();

      Get.snackbar(
        'Success',
        event.price > 0
            ? (amountPaid != null
                  ? 'Successfully enrolled with payment completed!'
                  : 'Enrollment initiated. Please complete payment.')
            : 'Successfully enrolled in the event!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      isEnrolling.value = false;
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to enroll: ${e.toString()}');
      isEnrolling.value = false;
      return false;
    }
  }

  // ... rest of the methods (completePayment, cancelEnrollment, etc.) with similar fixes
  // Make sure to use orgId instead of organizerUid in all organization references

  Future<void> completePayment(String enrollmentId, double amountPaid) async {
    try {
      final enrollment = studentEnrollments.firstWhere(
        (e) => e.enrollmentId == enrollmentId,
        orElse: () => EventEnrollment(
          enrollmentId: '',
          eventId: '',
          studentUid: '',
          organizerUid: '',
          orgId: '',
          eventTitle: '',
          amountPaid: 0,
          paymentStatus: '',
          enrollmentStatus: '',
          enrolledAt: DateTime.now(),
        ),
      );

      // Verify payment amount matches event price
      if (enrollment.amountPaid != amountPaid) {
        Get.snackbar('Error', 'Payment amount does not match event price.');
        return;
      }

      final batch = _firestore.batch();

      // Update main enrollment
      batch.update(_firestore.collection('enrollments').doc(enrollmentId), {
        'paymentStatus': 'completed',
        'paymentCompletedAt': FieldValue.serverTimestamp(),
        'amountPaid': amountPaid,
      });

      // Update student subcollection
      batch.update(
        _firestore
            .collection('students')
            .doc(enrollment.studentUid)
            .collection('enrollments')
            .doc(enrollmentId),
        {
          'paymentStatus': 'completed',
          'paymentCompletedAt': FieldValue.serverTimestamp(),
          'amountPaid': amountPaid,
        },
      );

      // Update organization subcollection (using orgId)
      batch.update(
        _firestore
            .collection('organizations')
            .doc(enrollment.orgId) // Use orgId
            .collection('events')
            .doc(enrollment.eventId)
            .collection('enrollments')
            .doc(enrollmentId),
        {
          'paymentStatus': 'completed',
          'paymentCompletedAt': FieldValue.serverTimestamp(),
          'amountPaid': amountPaid,
        },
      );

      await batch.commit();

      Get.snackbar('Success', 'Payment completed successfully!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to complete payment: ${e.toString()}');
    }
  }

  Future<void> cancelEnrollment(String enrollmentId) async {
    try {
      isCancelling.value = true;

      final enrollment = studentEnrollments.firstWhere(
        (e) => e.enrollmentId == enrollmentId,
      );

      if (enrollment.amountPaid > 0 &&
          enrollment.paymentStatus == 'completed') {
        Get.snackbar(
          'Error',
          'Cannot cancel enrollment after payment is completed.',
        );
        isCancelling.value = false;
        return;
      }

      final batch = _firestore.batch();

      // Update enrollment status
      batch.update(_firestore.collection('enrollments').doc(enrollmentId), {
        'enrollmentStatus': 'cancelled',
      });

      // Update student subcollection
      batch.update(
        _firestore
            .collection('students')
            .doc(enrollment.studentUid)
            .collection('enrollments')
            .doc(enrollmentId),
        {'enrollmentStatus': 'cancelled'},
      );

      // Update organization subcollection (using orgId)
      batch.update(
        _firestore
            .collection('organizations')
            .doc(enrollment.orgId)
            .collection('events')
            .doc(enrollment.eventId)
            .collection('enrollments')
            .doc(enrollmentId),
        {'enrollmentStatus': 'cancelled'},
      );

      // Decrement event enrollment count (using orgId)
      batch.update(
        _firestore
            .collection('organizations')
            .doc(enrollment.orgId)
            .collection('events')
            .doc(enrollment.eventId),
        {'enrolledCount': FieldValue.increment(-1)},
      );

      // Update allEvents collection
      batch.update(_firestore.collection('allEvents').doc(enrollment.eventId), {
        'enrolledCount': FieldValue.increment(-1),
      });

      await batch.commit();

      Get.snackbar('Success', 'Enrollment cancelled successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to cancel enrollment: ${e.toString()}');
    } finally {
      isCancelling.value = false; // ← Set to false when done
    }
  }

  // Helper method to check if user is enrolled in an event
  Future<bool> isUserEnrolled(String eventId) async {
    final user = _authController.user.value;
    if (user == null) return false;

    final enrollment = await _firestore
        .collection('enrollments')
        .where('eventId', isEqualTo: eventId)
        .where('studentUid', isEqualTo: user.uid)
        .where('enrollmentStatus', isEqualTo: 'registered')
        .get();

    return enrollment.docs.isNotEmpty;
  }

  // Add these methods to your existing EnrollmentController class

  User? getCurrentUser() {
    return _authController.user.value;
  }

  Future<EventEnrollment?> getUserEnrollmentForEvent(
    String userId,
    String eventId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('enrollments')
          .where('studentUid', isEqualTo: userId)
          .where('eventId', isEqualTo: eventId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return EventEnrollment.fromJson(snapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
