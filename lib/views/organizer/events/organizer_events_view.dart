import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/organizer/organizer_events_controller.dart';
import '../../../data/model/event.dart';
import '../../../routes/app_routes.dart';

class OrganizerEventsView extends StatelessWidget {
  final OrganizerEventsController controller = Get.put(
    OrganizerEventsController(),
  );

  OrganizerEventsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          IconButton(
            onPressed: controller.refreshEvents,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.organizerCreateEvent),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.refreshEvents();
        },
        child: Obx(() {
          if (controller.isLoading.value && controller.events.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No events created yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        Get.toNamed(AppRoutes.organizerCreateEvent),
                    child: const Text('Create Your First Event'),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: DataTable2(
              columnSpacing: 12,
              horizontalMargin: 12,
              minWidth: 800,
              headingRowColor: MaterialStateColor.resolveWith(
                (states) => Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              columns: const [
                DataColumn2(label: Text('Event'), size: ColumnSize.L),
                DataColumn2(label: Text('Date')),
                DataColumn2(label: Text('Venue')),
                DataColumn2(label: Text('Status')),
                DataColumn2(label: Text('Enrollments')),
                DataColumn2(label: Text('Actions')),
              ],
              rows: controller.events.map((event) {
                return DataRow2(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 200,
                        child: Text(
                          event.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(DateFormat('MMM dd, yyyy').format(event.startAt)),
                    ),
                    DataCell(
                      SizedBox(
                        width: 120,
                        child: Text(
                          event.venue,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: event.approved
                              ? Colors.green.withOpacity(0.1)
                              : event.conflict
                              ? Colors.red.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          event.approved
                              ? 'Approved'
                              : event.conflict
                              ? 'Conflict'
                              : 'Pending',
                          style: TextStyle(
                            fontSize: 12,
                            color: event.approved
                                ? Colors.green
                                : event.conflict
                                ? Colors.red
                                : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text('${event.enrolledCount}/${event.capacity}')),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              // TODO: View event details
                            },
                            icon: const Icon(Icons.visibility, size: 20),
                            tooltip: 'View',
                          ),
                          IconButton(
                            onPressed: () {
                              // TODO: Edit event
                            },
                            icon: const Icon(Icons.edit, size: 20),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            onPressed: () => _showNotifyDialog(event),
                            icon: const Icon(Icons.notifications, size: 20),
                            tooltip: 'Notify Enrollments',
                          ),
                          IconButton(
                            onPressed: () => _showDeleteDialog(event),
                            icon: const Icon(Icons.delete, size: 20),
                            tooltip: 'Delete',
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          );
        }),
      ),
    );
  }

  void _showNotifyDialog(Event event) {
    Get.defaultDialog(
      title: 'Notify Enrollments',
      middleText:
          'Send notification to all students enrolled in "${event.title}"?',
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            Get.back();
            controller.notifyEnrollments(event.eventId);
          },
          child: const Text('Send'),
        ),
      ],
    );
  }

  void _showDeleteDialog(Event event) {
    Get.defaultDialog(
      title: 'Delete Event',
      middleText:
          'Are you sure you want to delete "${event.title}"? This action cannot be undone.',
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            Get.back();
            controller.deleteEvent(event.eventId);
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
