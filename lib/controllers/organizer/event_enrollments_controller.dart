import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_board/data/model/student.dart';
import 'package:get/get.dart';

import '../../data/model/event.dart';
import '../../data/model/event_enrollment.dart';

class EventEnrollmentsController extends GetxController {
  final Event event;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<EventEnrollment> enrollments = <EventEnrollment>[].obs;
  final RxList<Student> students = <Student>[].obs;
  final RxBool isLoading = true.obs;

  EventEnrollmentsController(this.event);

  @override
  void onInit() {
    super.onInit();
    fetchEnrollments();
  }

  Future<void> fetchEnrollments() async {
    try {
      isLoading.value = true;

      // Query the main enrollments collection directly
      final enrollmentSnapshot = await _firestore
          .collection('enrollments')
          .where('eventId', isEqualTo: event.eventId)
          .get();

      if (enrollmentSnapshot.docs.isNotEmpty) {
        final enrollmentList = enrollmentSnapshot.docs
            .map((doc) => EventEnrollment.fromJson(doc.data()))
            .toList();
        enrollments.value = enrollmentList;

        // Fetch student details for each enrollment
        final studentUids = enrollmentList
            .map((e) => e.studentUid)
            .toSet()
            .toList();

        if (studentUids.isNotEmpty) {
          // Process in batches of 10 (Firestore limit for 'whereIn')
          final List<Student> allStudents = [];

          for (int i = 0; i < studentUids.length; i += 10) {
            final batchIds = studentUids.sublist(
              i,
              i + 10 > studentUids.length ? studentUids.length : i + 10,
            );

            final studentSnapshot = await _firestore
                .collection('students')
                .where(FieldPath.documentId, whereIn: batchIds)
                .get();

            final batchStudents = studentSnapshot.docs
                .map((doc) => Student.fromJson(doc.data()))
                .toList();

            allStudents.addAll(batchStudents);
          }

          students.value = allStudents;
        }
      } else {
        enrollments.value = [];
        students.value = [];
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch enrollments: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to get student by UID
  Student getStudentByUid(String uid) {
    return students.firstWhere(
      (student) => student.uid == uid,
      orElse: () => Student(
        uid: uid,
        displayName: 'Unknown Student',
        email: 'Unknown',
        studentId: 'N/A',
        batch: 'N/A',
        interests: [],
        fcmTokens: [],
        createdAt: DateTime.now(),
      ),
    );
  }

  // Refresh enrollments
  Future<void> refreshEnrollments() async {
    await fetchEnrollments();
  }
}
