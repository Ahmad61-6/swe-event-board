import 'package:event_board/data/model/event.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/enrollment_controller.dart';

class EventDetailView extends StatelessWidget {
  final Event event;
  final EnrollmentController enrollmentController = Get.find();

  EventDetailView({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            pinned: true,
            floating: false,
            backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
            foregroundColor: isDarkMode ? Colors.white : Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                event.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.8),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    event.bannerUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Status Chip
                  _buildStatusChip(event, theme),
                  const SizedBox(height: 20),

                  // Event Title
                  Text(
                    event.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Event Type
                  Text(
                    event.type.toUpperCase(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Event Details Grid
                  _buildEventDetailsGrid(event, theme),
                  const SizedBox(height: 24),

                  // About Section
                  _buildAboutSection(event, theme),
                  const SizedBox(height: 32),

                  // Enrollment/Cancellation Button
                  _buildEnrollmentButton(event, theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(Event event, ThemeData theme) {
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
        statusText = 'Pending Approval';
    }

    return Chip(
      label: Text(
        statusText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: statusColor,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildEventDetailsGrid(Event event, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Date and Time
            _buildDetailRow(
              icon: Icons.calendar_today,
              title: 'Date & Time',
              value:
                  '${DateFormat('MMM dd, yyyy').format(event.startAt)} • '
                  '${DateFormat('hh:mm a').format(event.startAt)} - '
                  '${DateFormat('hh:mm a').format(event.endAt)}',
              theme: theme,
            ),
            const SizedBox(height: 16),

            // Location
            _buildDetailRow(
              icon: Icons.location_on,
              title: 'Location',
              value: event.venue,
              theme: theme,
            ),
            const SizedBox(height: 16),

            // Online Meeting (if available)
            if (event.meetLink.isNotEmpty)
              Column(
                children: [
                  _buildDetailRow(
                    icon: Icons.video_call,
                    title: 'Online Meeting',
                    value: 'Available',
                    theme: theme,
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      // Handle meeting link tap
                      Get.snackbar(
                        'Meeting Link',
                        'Join meeting: ${event.meetLink}',
                      );
                    },
                    child: Text(
                      'Join Meeting',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Price and Capacity
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.attach_money,
                    title: 'Price',
                    value: event.price > 0 ? 'BDT ${event.price}' : 'Free',
                    color: event.price > 0 ? Colors.blue : Colors.green,
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    icon: Icons.people,
                    title: 'Capacity',
                    value: '${event.enrolledCount}/${event.capacity}',
                    color: Colors.purple,
                    theme: theme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(Event event, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About the Event',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: theme.primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          event.description.isNotEmpty
              ? event.description
              : 'No description available for this event.',
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.6,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }

  Future<bool> _isUserEnrolled() async {
    return await enrollmentController.isUserEnrolled(event.eventId);
  }

  Widget _buildEnrollmentButton(Event event, ThemeData theme) {
    return FutureBuilder<bool>(
      future: _isUserEnrolled(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final isEnrolled = snapshot.data ?? false;

        if (isEnrolled) {
          // User is already enrolled - show cancellation options
          return _buildCancellationSection(event, theme);
        } else {
          // User is not enrolled - show enrollment button
          return _buildEnrollmentSection(event, theme);
        }
      },
    );
  }

  Widget _buildCancellationSection(Event event, ThemeData theme) {
    return Obx(() {
      final isCancelling = enrollmentController.isCancelling.value;
      final isPaidEvent = event.price > 0;

      return Column(
        children: [
          // Already enrolled status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Already Enrolled',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isPaidEvent
                            ? 'Payment completed - BDT ${event.price}'
                            : 'Free enrollment',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Cancel enrollment button (only for free events)
          if (!isPaidEvent)
            ElevatedButton(
              onPressed: isCancelling
                  ? null
                  : () => _showCancelEnrollmentDialog(event),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: isCancelling
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cancel, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Cancel Enrollment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),

          // Message for paid events
          if (isPaidEvent)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.orange, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Paid enrollments cannot be cancelled',
                      style: TextStyle(fontSize: 14, color: Colors.orange[700]),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _buildEnrollmentSection(Event event, ThemeData theme) {
    return Obx(() {
      final isEnrolling = enrollmentController.isEnrolling.value;
      final isEventFull = event.enrolledCount >= event.capacity;
      final isApproved = event.approvalStatus == 'approved';

      if (!isApproved) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.orange, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'This event is pending approval. Enrollment will be available once approved.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          ElevatedButton(
            onPressed: isEventFull || isEnrolling
                ? null
                : () => _handleEnrollment(event),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: isEventFull
                  ? Colors.grey
                  : event.price > 0
                  ? theme.primaryColor
                  : Colors.green,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: theme.primaryColor.withOpacity(0.3),
            ),
            child: isEnrolling
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isEventFull ? Icons.group_off : Icons.event_available,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isEventFull
                            ? 'Event Full'
                            : event.price > 0
                            ? 'Enroll Now - BDT ${event.price}'
                            : 'Enroll for Free',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
          if (isEventFull)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(
                'This event has reached its maximum capacity',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      );
    });
  }

  void _showCancelEnrollmentDialog(Event event) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Enrollment'),
        content: Text(
          'Are you sure you want to cancel your enrollment for "${event.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Keep Enrollment'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _cancelEnrollment(event);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Enrollment'),
          ),
        ],
      ),
    );
  }

  void _cancelEnrollment(Event event) async {
    try {
      // Get the user's enrollment for this event
      final user = enrollmentController.getCurrentUser();
      if (user == null) return;

      final enrollment = await enrollmentController.getUserEnrollmentForEvent(
        user.uid,
        event.eventId,
      );

      if (enrollment != null) {
        await enrollmentController.cancelEnrollment(enrollment.enrollmentId);

        Get.snackbar(
          'Cancelled',
          'Enrollment cancelled successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel enrollment: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _handleEnrollment(Event event) async {
    if (event.price > 0) {
      // Show payment dialog for paid events
      final result = await Get.dialog<bool>(
        Dialog(
          backgroundColor: Theme.of(Get.context!).dialogTheme.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.payment,
                  size: 48,
                  color: Theme.of(Get.context!).primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Payment Required',
                  style: Theme.of(Get.context!).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'This event requires payment of BDT ${event.price}. '
                  'Do you want to proceed with payment?',
                  textAlign: TextAlign.center,
                  style: Theme.of(Get.context!).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(result: false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.back(result: true),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Pay Now'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      if (result == true) {
        final enrollmentSuccess = await enrollmentController.enrollToEvent(
          event,
          amountPaid: event.price,
        );
        if (enrollmentSuccess) {
          Get.snackbar(
            '🎉 Success!',
            'Enrolled successfully with payment completed!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      }
    } else {
      final enrollmentSuccess = await enrollmentController.enrollToEvent(event);
      if (enrollmentSuccess) {
        Get.snackbar(
          '🎉 Success!',
          'Successfully enrolled in the event!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }
}
