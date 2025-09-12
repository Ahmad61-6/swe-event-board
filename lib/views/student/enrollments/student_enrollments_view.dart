import 'package:event_board/views/student/events/event_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/student/student_enrollments_controller.dart';
import '../../../data/model/event.dart';
import '../../../data/model/event_enrollment.dart';

class StudentEnrollmentsView extends StatelessWidget {
  final StudentEnrollmentsController controller = Get.put(
    StudentEnrollmentsController(),
  );

  StudentEnrollmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Enrollments')),
      body: Obx(() {
        if (controller.enrollments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'No enrollments yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Browse and enroll in events',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.enrollments.length,
          itemBuilder: (context, index) {
            final enrollment = controller.enrollments[index];
            final event = controller.getEventForEnrollment(enrollment);

            return GestureDetector(
              onTap: () {
                if (event != null) {
                  Get.to(EventDetailView(event: event));
                }
              },
              child: _buildEnrollmentCard(context, enrollment, event),
            );
          },
        );
      }),
    );
  }

  Widget _buildEnrollmentCard(
    BuildContext context,
    EventEnrollment enrollment,
    Event? event,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.8),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event title
            Text(
              event?.title ?? 'Unknown Event',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // Event details
            if (event != null) ...[
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMM dd, yyyy').format(event.startAt),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    event.venue,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),

            // Enrollment details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enrolled on',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(enrollment.enrolledAt),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: enrollment.paymentStatus == 'checked_in'
                        ? Colors.green.withAlpha(30)
                        : enrollment.paymentStatus == 'cancelled'
                        ? Colors.red.withAlpha(30)
                        : Colors.blue.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    enrollment.paymentStatus.replaceAll('_', ' ').toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: enrollment.paymentStatus == 'checked_in'
                          ? Colors.green
                          : enrollment.paymentStatus == 'cancelled'
                          ? Colors.red
                          : Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
