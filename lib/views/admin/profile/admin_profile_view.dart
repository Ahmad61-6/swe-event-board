import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../controllers/admin/admin_profile_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../data/services/storage_service.dart';

class AdminProfileView extends StatelessWidget {
  const AdminProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminProfileController controller = Get.put(AdminProfileController());
    final AuthController authController = Get.find();
    final StorageService storageService = Get.find();

    void pickAndUploadImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final adminId = controller.admin.value!.uid;
        final path = 'admins/$adminId/profile.jpg';
        final imageUrl = await storageService.uploadImage(path, file);
        if (imageUrl != null) {
          final updatedAdmin = controller.admin.value!.copyWith(profileImageUrl: imageUrl);
          await controller.updateAdmin(updatedAdmin);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Profile'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.admin.value == null) {
          return const Center(child: Text('Could not load admin profile.'));
        }

        final admin = controller.admin.value!;

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: pickAndUploadImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: admin.profileImageUrl != null && admin.profileImageUrl!.isNotEmpty
                        ? NetworkImage(admin.profileImageUrl!)
                        : null,
                    child: admin.profileImageUrl == null || admin.profileImageUrl!.isEmpty
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Administrator',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  admin.email,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
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
                            Get.back(); // Close dialog
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
              ],
            ),
          ),
        );
      }),
    );
  }
}
