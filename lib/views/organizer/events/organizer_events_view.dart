import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/organizer/organizer_events_controller.dart';
import '../../../data/model/event.dart';
import '../../../routes/app_routes.dart';
import '../../student/event/event_detail_view.dart';
import 'create_event_view.dart';

class OrganizerEventsView extends StatelessWidget {
  final OrganizerEventsController controller = Get.put(
    OrganizerEventsController(),
  );

  OrganizerEventsView({super.key});

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

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width,
              ),
              child: PaginatedDataTable2(
                headingRowDecoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                ),
                columnSpacing: 10,
                horizontalMargin: 8,
                minWidth: 1000,
                columns: [
                  DataColumn2(
                    label: const Text('Event'),
                    size: ColumnSize.L,
                    numeric: false,
                  ),
                  DataColumn2(
                    label: const Text('Date'),
                    size: ColumnSize.S,
                    numeric: false,
                  ),
                  DataColumn2(
                    label: const Text('Venue'),
                    size: ColumnSize.S,
                    numeric: false,
                  ),
                  DataColumn2(
                    label: const Text('Status'),
                    size: ColumnSize.S,
                    numeric: false,
                  ),
                  DataColumn2(
                    label: const Text('Enrollments'),
                    size: ColumnSize.S,
                    numeric: true,
                  ),
                  DataColumn2(
                    label: const Text('Actions'),
                    size: ColumnSize.M,
                    numeric: false,
                  ),
                ],
                source: EventDataSource(
                  controller.events,
                  context,
                  onView: (event) =>
                      Get.to(() => EventDetailView(event: event)),
                  onEdit: (event) =>
                      Get.to(() => CreateEventView(event: event)),
                  onNotify: _showNotifyDialog,
                  onDelete: _showDeleteDialog,
                ),
              ),
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

class EventDataSource extends DataTableSource {
  final List<Event> events;
  final BuildContext context;
  final Function(Event) onView;
  final Function(Event) onEdit;
  final Function(Event) onNotify;
  final Function(Event) onDelete;

  EventDataSource(
    this.events,
    this.context, {
    required this.onView,
    required this.onEdit,
    required this.onNotify,
    required this.onDelete,
  });

  @override
  DataRow getRow(int index) {
    final event = events[index];

    // Determine status color and text based on approvalStatus
    Color statusColor;
    String statusText;

    switch (event.approvalStatus) {
      case 'approved':
        statusColor = Colors.green;
        statusText = 'Approved';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'Rejected';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'Pending';
    }

    // Check if the row has data
    final hasData = event.title.isNotEmpty && event.venue.isNotEmpty;

    return DataRow2(
      onTap: () {
        Get.toNamed(AppRoutes.eventDetail, arguments: event);
      },
      cells: [
        DataCell(
          SizedBox(
            width: 180,
            child: Text(
              event.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        DataCell(Text(DateFormat('MMM dd, yyyy').format(event.startAt))),
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 12,
                color: statusColor,
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
                onPressed: () => onView(event),
                icon: const Icon(Icons.visibility, size: 20),
                tooltip: 'View',
              ),
              IconButton(
                onPressed: () => onEdit(event),
                icon: const Icon(Icons.edit, size: 20),
                tooltip: 'Edit',
              ),
              IconButton(
                onPressed: () => onNotify(event),
                icon: const Icon(Icons.notifications, size: 20),
                tooltip: 'Notify Enrollments',
              ),
              IconButton(
                onPressed: () => onDelete(event),
                icon: const Icon(Icons.delete, size: 20),
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ],
      decoration: BoxDecoration(
        border: hasData
            ? Border(bottom: BorderSide(color: Colors.grey[300]!))
            : null,
      ),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => events.length;

  @override
  int get selectedRowCount => 0;
}
