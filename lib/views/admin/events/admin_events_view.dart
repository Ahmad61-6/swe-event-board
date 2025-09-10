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
          Obx(
            () => Switch(
              value: controller.showPendingOnly.value,
              onChanged: (value) {
                controller.showPendingOnly.value = value;
              },
              activeTrackColor: Colors.orange.withValues(alpha: 0.5),
              activeColor: Colors.orange,
            ),
          ),
          const SizedBox(width: 8),
          const Text('Pending Only', style: TextStyle(fontSize: 12)),
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

          // Filter events based on pending only toggle
          final filteredEvents = controller.events.where((event) {
            if (controller.showPendingOnly.value) {
              return event.approvalStatus == 'pending';
            }
            return true;
          }).toList();

          if (filteredEvents.isEmpty && controller.showPendingOnly.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 64, color: Colors.green[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No pending events',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => controller.showPendingOnly.value = false,
                    child: const Text('View all events'),
                  ),
                ],
              ),
            );
          }

          return DataTable2(
            columnSpacing: 12,
            horizontalMargin: 12,
            minWidth: 1000,
            headingRowColor: WidgetStateColor.resolveWith(
              (states) => Theme.of(context).primaryColor.withValues(alpha: 0.1),
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
            rows: filteredEvents.map((event) {
              final org = controller.getOrganizationForEvent(event);

              // Determine status color and text
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
                        color: statusColor.withOpacity(0.1),
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
                        if (event.approvalStatus == 'pending')
                          IconButton(
                            onPressed: () => _showApprovalDialog(event, true),
                            icon: const Icon(
                              Icons.check,
                              size: 20,
                              color: Colors.green,
                            ),
                            tooltip: 'Approve',
                          ),
                        if (event.approvalStatus != 'pending')
                          IconButton(
                            onPressed: () => _showApprovalDialog(event, false),
                            icon: const Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.red,
                            ),
                            tooltip: event.approvalStatus == 'approved'
                                ? 'Reject'
                                : 'Set to Pending',
                          ),
                        IconButton(
                          onPressed: () => _viewEventDetails(event),
                          icon: const Icon(Icons.visibility, size: 20),
                          tooltip: 'View Details',
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          );
        }),
      ),
    );
  }

  void _showApprovalDialog(Event event, bool approve) {
    final currentStatus = event.approvalStatus;
    String title;
    String message;
    String actionText;

    if (approve) {
      title = 'Approve Event';
      message = 'Are you sure you want to approve "${event.title}"?';
      actionText = 'Approve';
    } else if (currentStatus == 'approved') {
      title = 'Reject Event';
      message = 'Are you sure you want to reject "${event.title}"?';
      actionText = 'Reject';
    } else {
      title = 'Set to Pending';
      message =
          'Are you sure you want to set "${event.title}" back to pending?';
      actionText = 'Set Pending';
    }

    Get.defaultDialog(
      title: title,
      middleText: message,
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            Get.back();
            if (approve) {
              controller.approveEvent(event.eventId, true);
            } else if (currentStatus == 'approved') {
              controller.approveEvent(event.eventId, false);
            } else {
              controller.setEventToPending(event.eventId);
            }
          },
          child: Text(actionText),
        ),
      ],
    );
  }

  void _viewEventDetails(Event event) {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (event.bannerUrl.isNotEmpty)
                  Image.network(
                    event.bannerUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 40),
                      );
                    },
                  ),
                const SizedBox(height: 16),
                _buildDetailRow('Description:', event.description),
                _buildDetailRow('Type:', event.type),
                _buildDetailRow(
                  'Start:',
                  DateFormat('MMM dd, yyyy - HH:mm').format(event.startAt),
                ),
                _buildDetailRow(
                  'End:',
                  DateFormat('MMM dd, yyyy - HH:mm').format(event.endAt),
                ),
                _buildDetailRow('Venue:', event.venue),
                _buildDetailRow('Price:', '₹${event.price}'),
                _buildDetailRow('Capacity:', event.capacity.toString()),
                _buildDetailRow('Enrolled:', event.enrolledCount.toString()),
                _buildDetailRow('Status:', event.approvalStatus.toUpperCase()),
                _buildDetailRow('Conflict:', event.conflict ? 'Yes' : 'No'),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value, softWrap: true)),
        ],
      ),
    );
  }
}
