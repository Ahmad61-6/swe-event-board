import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../data/model/enrollment.dart';
import '../../data/model/event.dart';
import '../auth_controller.dart';

class StudentEnrollmentsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<Enrollment> enrollments = <Enrollment>[].obs;
  final RxList<Event> events = <Event>[].obs;
  final RxBool isLoading = true.obs;

  DocumentSnapshot? _lastEnrollmentDoc;
  static const int _pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    _loadEnrollments();
  }

  Future<void> _loadEnrollments({bool refresh = false}) async {
    try {
      if (refresh) {
        isLoading.value = true;
        _lastEnrollmentDoc = null;
        enrollments.clear();
        events.clear();
      }

      final user = Get.find<AuthController>().user.value;
      if (user == null) return;

      Query query = _firestore
          .collectionGroup('enrollments')
          .where('studentUid', isEqualTo: user.uid)
          .orderBy('registeredAt', descending: true);

      if (_lastEnrollmentDoc != null) {
        query = query.startAfterDocument(_lastEnrollmentDoc!);
      }

      query = query.limit(_pageSize);

      QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        _lastEnrollmentDoc = snapshot.docs.last;

        List<Enrollment> newEnrollments = snapshot.docs
            .map(
              (doc) => Enrollment.fromJson(doc.data() as Map<String, dynamic>),
            )
            .toList();

        if (refresh) {
          enrollments.value = newEnrollments;
        } else {
          enrollments.addAll(newEnrollments);
        }

        // Load associated events
        await _loadAssociatedEvents(newEnrollments);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load enrollments');
    } finally {
      if (refresh) {
        isLoading.value = false;
      }
    }
  }

  Future<void> _loadAssociatedEvents(List<Enrollment> enrollmentsList) async {
    try {
      // Group enrollments by eventId to avoid duplicate queries
      Map<String, Enrollment> enrollmentMap = {};
      for (var enrollment in enrollmentsList) {
        enrollmentMap[enrollment.enrollId] = enrollment;
      }

      // Fetch events (this is simplified - in reality you'd need to know the org path)
      // For demo purposes, we'll just create placeholder events
      List<Event> newEvents = [];
      for (var enrollment in enrollmentsList) {
        // In a real implementation, you'd query the actual event
        newEvents.add(
          Event(
            eventId: enrollment.enrollId,
            title: 'Event ${enrollment.enrollId.substring(0, 8)}',
            description: 'Event description',
            type: 'Tech Talk',
            bannerUrl: '',
            startAt: DateTime.now().add(const Duration(days: 7)),
            endAt: DateTime.now().add(const Duration(days: 7, hours: 2)),
            venue: 'Main Auditorium',
            meetLink: '',
            price: 0,
            capacity: 100,
            createdByUid: 'org123',
            approved: true,
            enrolledCount: 45,
            conflict: false,
            createdAt: DateTime.now(),
          ),
        );
      }

      if (enrollments.length == newEvents.length) {
        events.addAll(newEvents);
      }
    } catch (e) {
      // Handle error silently or show message
    }
  }

  Future<void> loadMoreEnrollments() async {
    if (_lastEnrollmentDoc == null) return;
    await _loadEnrollments();
  }

  Future<void> refreshEnrollments() async {
    await _loadEnrollments(refresh: true);
  }

  Event? getEventForEnrollment(Enrollment enrollment) {
    // Find associated event
    for (int i = 0; i < enrollments.length; i++) {
      if (i < events.length && enrollments[i].enrollId == enrollment.enrollId) {
        return events[i];
      }
    }
    return null;
  }
}
