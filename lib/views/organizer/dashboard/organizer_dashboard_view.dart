import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/organizer/organizer_dashboard_controller.dart';
import '../../../routes/app_routes.dart';

class OrganizerDashboardView extends StatefulWidget {
  const OrganizerDashboardView({super.key});

  @override
  State<OrganizerDashboardView> createState() => _OrganizerDashboardViewState();
}

class _OrganizerDashboardViewState extends State<OrganizerDashboardView> {
  final OrganizerDashboardController controller = Get.put(
    OrganizerDashboardController(),
  );

  @override
  void initState() {
    super.initState();
    controller.refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizer Dashboard'),
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
                // Organization Info
                _buildOrganizationInfo(context: context),

                const SizedBox(height: 24),

                // KPI Cards
                _buildKPICards(),

                const SizedBox(height: 24),

                // Quick Actions
                _buildQuickActions(context),

                const SizedBox(height: 24),

                // Recent Events
                _buildRecentEvents(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrganizationInfo({required BuildContext context}) {
    return Obx(() {
      if (controller.organization.value == null) {
        return const SizedBox();
      }

      final org = controller.organization.value!;
      return Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 2,
            color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  org.type == 'clubs'
                      ? Icons.groups
                      : org.type == 'departments'
                      ? Icons.business
                      : Icons.handshake,
                  color: Theme.of(context).primaryColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      org.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: org.approved
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            org.approved ? 'Approved' : 'Pending Approval',
                            style: TextStyle(
                              fontSize: 12,
                              color: org.approved
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          org.type.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildKPICards() {
    return Obx(() {
      if (controller.isLoadingKPIs.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return Row(
        children: [
          Expanded(
            child: _buildKPIWidget(
              title: 'Total Events',
              value: controller.totalEvents.toString(),
              icon: Icons.event,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildKPIWidget(
              title: 'Total Enrollments',
              value: controller.totalEnrollments.toString(),
              icon: Icons.people,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildKPIWidget(
              title: 'Revenue',
              value:
                  'BDT${NumberFormat('#,##0').format(controller.totalRevenue.value)}',
              icon: Icons.attach_money,
              color: Colors.orange,
            ),
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
        side: BorderSide(color: color.withValues(alpha: 0.6), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Theme.of(context).primaryColor, width: 2),
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
                    title: 'Create Event',
                    icon: Icons.add_circle,
                    color: Theme.of(context).primaryColor,
                    onTap: () => Get.toNamed(AppRoutes.organizerCreateEvent),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    context,
                    title: 'Add Merchandise',
                    icon: Icons.shopping_cart,
                    color: Colors.green,
                    onTap: () => Get.toNamed(AppRoutes.organizerMerchandise),
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
        backgroundColor: color.withValues(alpha: 0.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 32, fill: 0.5, weight: 0.5),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentEvents() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.recentEvents.isEmpty) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'No events created yet',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.toNamed(AppRoutes.organizerCreateEvent),
                  child: const Text('Create Your First Event'),
                ),
              ],
            ),
          ),
        );
      }

      return Card(
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.grey, width: 2),
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
                    'Recent Events',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.organizerEvents),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.recentEvents.length,
                itemBuilder: (context, index) {
                  final event = controller.recentEvents[index];
                  return ListTile(
                    title: Text(event.title),
                    subtitle: Text(
                      DateFormat('MMM dd, yyyy').format(event.startAt),
                    ),
                    trailing: Text('${event.enrolledCount} enrolled'),
                  );
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}
