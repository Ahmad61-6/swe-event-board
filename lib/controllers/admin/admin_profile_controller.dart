import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:event_board/data/services/network_service.dart';

import '../../data/model/admin.dart';
import '../auth_controller.dart';

class AdminProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NetworkService _networkService = Get.find();
  final Rx<Admin?> admin = Rx<Admin?>(null);
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadAdminProfile();
  }

  Future<void> loadAdminProfile() async {
    try {
      isLoading.value = true;
      if (!await _networkService.isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        isLoading.value = false;
        return;
      }
      final user = Get.find<AuthController>().user.value;
      if (user == null) {
        isLoading.value = false;
        return;
      }

      final doc = await _firestore
          .collection('admins')
          .doc(user.uid)
          .collection('details')
          .doc('profile')
          .get();

      if (doc.exists) {
        admin.value = Admin.fromJson(doc.data()!);
      } else {
        Get.snackbar('Error', 'Admin profile not found.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load admin profile: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateAdmin(Admin ad) async {
    try {
      if (!await _networkService.isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        return;
      }
      await _firestore
          .collection('admins')
          .doc(ad.uid)
          .collection('details')
          .doc('profile')
          .update(ad.toJson());
      admin.value = ad;
      Get.snackbar('Success', 'Profile updated successfully!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: ${e.toString()}');
    }
  }
}
