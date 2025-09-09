import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/admin/admin_users_controller.dart';
import '../../../data/model/organization.dart';
import '../../../data/model/student.dart';

class AdminUsersView extends StatelessWidget {
  final AdminUsersController controller = Get.put(AdminUsersController());

  AdminUsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Management'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Students'),
              Tab(text: 'Organizers'),
            ],
          ),
          actions: [
            IconButton(
              onPressed: controller.refreshUsers,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await controller.refreshUsers();
          },
          child: TabBarView(
            children: [
              // Students Tab
              _buildStudentsTab(context: context),
              // Organizers Tab
              _buildOrganizersTab(context: context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentsTab({required BuildContext context}) {
    return Obx(() {
      if (controller.isLoading.value && controller.students.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: DataTable2(
          columnSpacing: 12,
          horizontalMargin: 12,
          minWidth: 800,
          headingRowColor: WidgetStateColor.resolveWith(
            (states) => Theme.of(context).primaryColor.withValues(alpha: 0.1),
          ),
          columns: const [
            DataColumn2(label: Text('Student'), size: ColumnSize.L),
            DataColumn2(label: Text('ID')),
            DataColumn2(label: Text('Batch')),
            DataColumn2(label: Text('Joined')),
            DataColumn2(label: Text('Actions')),
          ],
          rows: controller.students.map((student) {
            return DataRow2(
              cells: [
                DataCell(
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.grey,
                        child: Icon(
                          Icons.person,
                          size: 15,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              student.email,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(Text(student.studentId)),
                DataCell(Text(student.batch)),
                DataCell(
                  Text(DateFormat('MMM dd, yyyy').format(student.createdAt)),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          // TODO: View student details
                        },
                        icon: const Icon(Icons.visibility, size: 20),
                        tooltip: 'View',
                      ),
                      IconButton(
                        onPressed: () => _showDeleteDialog(student, 'student'),
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
    });
  }

  Widget _buildOrganizersTab({required BuildContext context}) {
    return Obx(() {
      if (controller.isLoading.value && controller.organizers.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: DataTable2(
          columnSpacing: 12,
          horizontalMargin: 12,
          minWidth: 800,
          headingRowColor: WidgetStateColor.resolveWith(
            (states) => Theme.of(context).primaryColor.withValues(alpha: 0.1),
          ),
          columns: const [
            DataColumn2(label: Text('Organizer'), size: ColumnSize.L),
            DataColumn2(label: Text('Type')),
            DataColumn2(label: Text('Status')),
            DataColumn2(label: Text('Created')),
            DataColumn2(label: Text('Actions')),
          ],
          rows: controller.organizers.map((org) {
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
                          ).primaryColor.withValues(alpha: 0.1),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              org.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              org.contactEmail,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
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
                  Text(DateFormat('MMM dd, yyyy').format(org.createdAt)),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          // TODO: View organizer details
                        },
                        icon: const Icon(Icons.visibility, size: 20),
                        tooltip: 'View',
                      ),
                      IconButton(
                        onPressed: () => _showDeleteDialog(org, 'organizer'),
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
    });
  }

  void _showDeleteDialog(dynamic user, String userType) {
    String userName = userType == 'student'
        ? (user as Student).displayName
        : (user as Organization).name;

    Get.defaultDialog(
      title: 'Delete User',
      middleText:
          'Are you sure you want to delete "$userName"? This action cannot be undone.',
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            Get.back();
            controller.deleteUser(
              userType == 'student' ? user.uid : user.orgId,
              userType,
            );
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
