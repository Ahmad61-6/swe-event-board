import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/student/event_detail_controller.dart';

class EventDetailView extends StatelessWidget {
  final EventDetailController controller = Get.put(EventDetailController());

  EventDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Details')),
      body: Obx(() {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Image
              SizedBox(
                height: 200,
                width: double.infinity,
                child: controller.event.bannerUrl.isNotEmpty
                    ? Image.network(
                        controller.event.bannerUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 50),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 50),
                      ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Type
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            controller.event.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            controller.event.type,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Date and Time
                    _buildInfoRow(
                      icon: Icons.calendar_today,
                      title: 'Date & Time',
                      content:
                          '${DateFormat('MMM dd, yyyy').format(controller.event.startAt)}\n'
                          '${DateFormat('hh:mm a').format(controller.event.startAt)} - '
                          '${DateFormat('hh:mm a').format(controller.event.endAt)}',
                      context: context,
                    ),

                    const SizedBox(height: 16),

                    // Venue
                    _buildInfoRow(
                      icon: Icons.location_on,
                      title: 'Venue',
                      content: controller.event.venue,
                      context: context,
                    ),

                    const SizedBox(height: 16),

                    // Online Link (if available)
                    if (controller.event.meetLink.isNotEmpty) ...[
                      _buildInfoRow(
                        icon: Icons.link,
                        title: 'Online Link',
                        content: controller.event.meetLink,
                        isLink: true,
                        context: context,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Price and Capacity
                    _buildInfoRow(
                      icon: Icons.attach_money,
                      title: 'Price',
                      content: controller.event.price > 0
                          ? '₹${controller.event.price.toStringAsFixed(0)}'
                          : 'Free',
                      trailing: Text(
                        '${controller.event.enrolledCount}/${controller.event.capacity} enrolled',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      context: context,
                    ),

                    const SizedBox(height: 24),

                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.event.description,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      bottomSheet: Obx(() {
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: controller.isEnrolled.value
              ? Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.generateQRCode,
                        child: controller.isLoading.value
                            ? const CircularProgressIndicator()
                            : const Text('Show QR Code'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.cancelEnrollment,
                        child: controller.isLoading.value
                            ? const CircularProgressIndicator()
                            : const Text('Cancel'),
                      ),
                    ),
                  ],
                )
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.enrollInEvent,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator()
                        : Text(
                            controller.event.price > 0
                                ? 'Enroll ₹${controller.event.price.toStringAsFixed(0)}'
                                : 'Enroll Free',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
        );
      }),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String content,
    required BuildContext context,
    Widget? trailing,
    bool isLink = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              if (isLink)
                GestureDetector(
                  onTap: () {
                    // TODO: Open link
                  },
                  child: Text(
                    content,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              else
                Text(content, style: const TextStyle(fontSize: 16)),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }
}
