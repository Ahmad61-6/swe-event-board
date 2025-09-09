import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/admin/admin_organizations_controller.dart';
import '../../../data/model/organization.dart';

class AdminOrganizationsView extends StatelessWidget {
  final AdminOrganizationsController controller = Get.put(
    AdminOrganizationsController(),
  );

  AdminOrganizationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organization Management'),
        actions: [
          IconButton(
            onPressed: controller.refreshOrganizations,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.refreshOrganizations();
        },
        child: Obx(() {
          if (controller.isLoading.value && controller.organizations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.organizations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.business, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No organizations found',
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
              minWidth: 800,
              headingRowColor: MaterialStateColor.resolveWith(
                (states) => Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              columns: const [
                DataColumn2(label: Text('Organization'), size: ColumnSize.L),
                DataColumn2(label: Text('Type')),
                DataColumn2(label: Text('Created')),
                DataColumn2(label: Text('Status')),
                DataColumn2(label: Text('Actions')),
              ],
              rows: controller.organizations.map((org) {
                return DataRow2(
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              org.type == 'clubs'
                                  ? Icons.groups
                                  : org.type == 'departments'
                                  ? Icons.business
                                  : Icons.handshake,
                              size: 18,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              org.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    DataCell(
                      Text(
                        org.type.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(DateFormat('MMM dd, yyyy').format(org.createdAt)),
                    ),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: org.approved
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          org.approved ? 'Approved' : 'Pending',
                          style: TextStyle(
                            fontSize: 12,
                            color: org.approved ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!org.approved)
                            IconButton(
                              onPressed: () => _showApprovalDialog(org, true),
                              icon: const Icon(
                                Icons.check,
                                size: 20,
                                color: Colors.green,
                              ),
                              tooltip: 'Approve',
                            ),
                          if (org.approved)
                            IconButton(
                              onPressed: () => _showApprovalDialog(org, false),
                              icon: const Icon(
                                Icons.close,
                                size: 20,
                                color: Colors.red,
                              ),
                              tooltip: 'Reject',
                            ),
                          IconButton(
                            onPressed: () {
                              // TODO: View organization details
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

  void _showApprovalDialog(Organization org, bool approve) {
    Get.defaultDialog(
      title: approve ? 'Approve Organization' : 'Reject Organization',
      middleText: approve
          ? 'Are you sure you want to approve "${org.name}"?'
          : 'Are you sure you want to reject "${org.name}"?',
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            Get.back();
            controller.approveOrganization(org.orgId, approve);
          },
          child: Text(approve ? 'Approve' : 'Reject'),
        ),
      ],
    );
  }
}
