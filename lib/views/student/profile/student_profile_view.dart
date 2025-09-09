import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/student/student_profile_controller.dart';
import '../../../data/services/storage_service.dart';

class StudentProfileView extends StatelessWidget {
  const StudentProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final StudentProfileController controller = Get.put(
      StudentProfileController(),
    );
    final AuthController authController = Get.find();
    final StorageService storageService = Get.find();

    void pickAndUploadImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final studentId = controller.student.value!.uid;
        final path = 'students/$studentId/profile.jpg';
        final imageUrl = await storageService.uploadImage(path, file);
        if (imageUrl != null) {
          final updatedStudent = controller.student.value!.copyWith(
            profileImageUrl: imageUrl,
          );
          await controller.updateStudent(updatedStudent);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.student.value == null) {
          return const Center(child: Text('Could not load student profile.'));
        }

        final student = controller.student.value!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: pickAndUploadImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      student.profileImageUrl != null &&
                          student.profileImageUrl!.isNotEmpty
                      ? NetworkImage(student.profileImageUrl!)
                      : null,
                  child:
                      student.profileImageUrl == null ||
                          student.profileImageUrl!.isEmpty
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                student.displayName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(student.email, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        Icons.credit_card,
                        'Student ID',
                        student.studentId,
                      ),
                      _buildDetailRow(Icons.class_, 'Batch', student.batch),
                      _buildDetailRow(
                        Icons.interests,
                        'Interests',
                        student.interests.join(', '),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => authController.signOut(),
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(value),
        ],
      ),
    );
  }
}
