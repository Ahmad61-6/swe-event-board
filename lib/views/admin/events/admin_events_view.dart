import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/admin/admin_events_controller.dart';
import '../../../data/model/event.dart';

class AdminEventsView extends StatelessWidget {
  final AdminEventsController controller = Get.put(AdminEventsController());

  AdminEventsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Management'),
        actions: [
          IconButton(
            onPressed: controller.refreshEvents,
            icon: const Icon(Icons.refresh),
          ),
        ],
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
                    'No events found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
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
              minWidth: 1000,
              headingRowColor: WidgetStateColor.resolveWith(
                (states) =>
                    Theme.of(context).primaryColor.withValues(alpha: 0.1),
              ),
              columns: const [
                DataColumn2(label: Text('Event'), size: ColumnSize.L),
                DataColumn2(label: Text('Organization')),
                DataColumn2(label: Text('Date')),
                DataColumn2(label: Text('Status')),
                DataColumn2(label: Text('Conflict')),
                DataColumn2(label: Text('Enrollments')),
                DataColumn2(label: Text('Actions')),
              ],
              rows: controller.events.map((event) {
                final org = controller.getOrganizationForEvent(event);
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
                      SizedBox(
                        width: 150,
                        child: Text(
                          org?.name ?? 'Unknown',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(DateFormat('MMM dd, yyyy').format(event.startAt)),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: event.approved
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          event.approved ? 'Approved' : 'Pending',
                          style: TextStyle(
                            fontSize: 12,
                            color: event.approved
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Icon(
                        event.conflict ? Icons.warning : Icons.check_circle,
                        color: event.conflict ? Colors.red : Colors.green,
                      ),
                    ),
                    DataCell(Text('${event.enrolledCount}/${event.capacity}')),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!event.approved)
                            IconButton(
                              onPressed: () => _showApprovalDialog(event, true),
                              icon: const Icon(
                                Icons.check,
                                size: 20,
                                color: Colors.green,
                              ),
                              tooltip: 'Approve',
                            ),
                          if (event.approved)
                            IconButton(
                              onPressed: () =>
                                  _showApprovalDialog(event, false),
                              icon: const Icon(
                                Icons.close,
                                size: 20,
                                color: Colors.red,
                              ),
                              tooltip: 'Reject',
                            ),
                          IconButton(
                            onPressed: () {
                              // TODO: View event details
                            },
                            icon: const Icon(Icons.visibility, size: 20),
                            tooltip: 'View',
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

  void _showApprovalDialog(Event event, bool approve) {
    Get.defaultDialog(
      title: approve ? 'Approve Event' : 'Reject Event',
      middleText: approve
          ? 'Are you sure you want to approve "${event.title}"?'
          : 'Are you sure you want to reject "${event.title}"?',
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            Get.back();
            controller.approveEvent(event.eventId, approve);
          },
          child: Text(approve ? 'Approve' : 'Reject'),
        ),
      ],
    );
  }
}
