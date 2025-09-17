import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/organizer/event_enrollments_controller.dart';
import '../../../data/model/event.dart';

class EventEnrollmentsView extends StatelessWidget {
  final Event event;

  const EventEnrollmentsView({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final EventEnrollmentsController controller = Get.put(
      EventEnrollmentsController(event),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Enrollments for ${event.title}'),
        actions: [
          IconButton(
            onPressed: controller.refreshEnrollments,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.enrollments.isEmpty) {
          return const Center(
            child: Text(
              'No students have enrolled in this event yet.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Student Name')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Student ID')),
                DataColumn(label: Text('Batch')),
                DataColumn(label: Text('Payment Status')),
                DataColumn(label: Text('Enrollment Status')),
                DataColumn(label: Text('Enrolled At')),
              ],
              rows: controller.enrollments.map((enrollment) {
                final student = controller.getStudentByUid(enrollment.studentUid);

                return DataRow(
                  cells: [
                    DataCell(Text(student.displayName)),
                    DataCell(Text(student.email)),
                    DataCell(Text(student.studentId)),
                    DataCell(Text(student.batch)),
                    DataCell(
                      Chip(
                        label: Text(
                          enrollment.paymentStatus.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: enrollment.paymentStatus == 'completed'
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                    DataCell(
                      Chip(
                        label: Text(
                          enrollment.enrollmentStatus.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor:
                            enrollment.enrollmentStatus == 'registered'
                                ? Colors.green
                                : Colors.orange,
                      ),
                    ),
                    DataCell(
                      Text(
                        DateFormat(
                          'MMM dd, yyyy HH:mm',
                        ).format(enrollment.enrolledAt),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      }),
    );
  }
}
