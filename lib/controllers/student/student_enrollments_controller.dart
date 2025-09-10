import 'package:event_board/data/static_data.dart';
import 'package:get/get.dart';

import '../../data/model/enrollment.dart';
import '../../data/model/event.dart';

class StudentEnrollmentsController extends GetxController {
  final RxList<Enrollment> enrollments = <Enrollment>[].obs;
  final RxList<Event> events = <Event>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadEnrollments();
  }

  void _loadEnrollments() {
    enrollments.value = StaticData.enrollments;
    events.value = StaticData.events.where((event) {
      return enrollments.any((enrollment) => enrollment.enrollId == event.eventId);
    }).toList();
  }

  Event? getEventForEnrollment(Enrollment enrollment) {
    return events.firstWhereOrNull((event) => event.eventId == enrollment.enrollId);
  }
}