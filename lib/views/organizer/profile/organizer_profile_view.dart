import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/organizer/organizer_profile_controller.dart';

class OrganizerProfileView extends StatelessWidget {
  const OrganizerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final OrganizerProfileController controller = Get.put(
      OrganizerProfileController(),
    );
    final AuthController authController = Get.find();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.organization.value == null) {
          return const Center(
            child: Text('Could not load organization profile.'),
          );
        }

        final org = controller.organization.value!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          org.logoUrl != null && org.logoUrl!.isNotEmpty
                          ? NetworkImage(org.logoUrl!)
                          : null,
                      child: org.logoUrl == null || org.logoUrl!.isEmpty
                          ? const Icon(Icons.business, size: 50)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      org.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Chip(
                      label: Text(org.type),
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor.withOpacity(0.1),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              _buildProfileCard(
                context,
                title: 'Organization Details',
                children: [
                  _buildDetailRow(Icons.person, 'Owner', org.name),
                  _buildDetailRow(
                    Icons.email,
                    'Contact Email',
                    org.contactEmail,
                  ),
                  _buildDetailRow(
                    Icons.check_circle,
                    'Status',
                    org.approved ? 'Approved' : 'Pending Approval',
                    valueColor: org.approved ? Colors.green : Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.defaultDialog(
                      title: 'Confirm Sign Out',
                      middleText: 'Are you sure you want to sign out?',
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.back();
                            authController.signOut();
                          },
                          child: const Text('Sign Out'),
                        ),
                      ],
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String title,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Text('$title:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: valueColor ?? Colors.black87),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
