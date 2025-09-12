import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/admin/admin_dashboard_controller.dart';
import '../../../routes/app_routes.dart';

class AdminDashboardView extends StatelessWidget {
  final AdminDashboardController controller = Get.put(
    AdminDashboardController(),
  );

  AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: controller.refreshData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.refreshData();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Message
                const Text(
                  'Welcome, Admin',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'System Overview',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),

                const SizedBox(height: 24),

                // System KPIs
                _buildSystemKPIs(),

                const SizedBox(height: 24),

                // Quick Actions
                _buildQuickActions(context),

                const SizedBox(height: 24),

                // Pending Approvals
                _buildPendingApprovals(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSystemKPIs() {
    return Obx(() {
      if (controller.isLoadingKPIs.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildKPIWidget(
                  title: 'Total Students',
                  value: controller.totalStudents.toString(),
                  icon: Icons.school,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKPIWidget(
                  title: 'Total Organizations',
                  value: controller.totalOrganizations.toString(),
                  icon: Icons.business,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildKPIWidget(
                  title: 'Total Events',
                  value: controller.totalEvents.toString(),
                  icon: Icons.event,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildKPIWidget(
                  title: 'Pending Events',
                  value: controller.pendingEvents.toString(),
                  icon: Icons.pending,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildKPIWidget({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.blue.withValues(alpha: 0.6), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    title: 'Manage Events',
                    icon: Icons.event,
                    color: Theme.of(context).primaryColor,
                    onTap: () => Get.toNamed(AppRoutes.adminEvents),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    context,
                    title: 'Manage Organizations',
                    icon: Icons.business,
                    color: Colors.green,
                    onTap: () => Get.toNamed(AppRoutes.adminOrganizations),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    context,
                    title: 'Manage Users',
                    icon: Icons.people,
                    color: Colors.orange,
                    onTap: () => Get.toNamed(AppRoutes.adminUsers),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    context,
                    title: 'Send Notifications',
                    icon: Icons.notifications,
                    color: Colors.purple,
                    onTap: () => Get.toNamed(AppRoutes.adminNotifications),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: color.withValues(alpha: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 32, weight: 1),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPendingApprovals() {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.blue.withValues(alpha: 0.6), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pending Approvals',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.adminEvents),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.pendingEvents.value == 0) {
                return Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 48,
                        color: Colors.green[300],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No pending approvals',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.pending, color: Colors.orange, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${controller.pendingEvents.value} events pending approval',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Get.toNamed(AppRoutes.adminEvents),
                      child: const Text('Review'),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
