import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:event_board/data/services/network_service.dart';

import '../../data/model/organization.dart';
import '../auth_controller.dart';

class OrganizerProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NetworkService _networkService = Get.find();
  final Rx<Organization?> organization = Rx<Organization?>(null);
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrganizationProfile();
  }

  Future<void> loadOrganizationProfile() async {
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

      final snapshot = await _firestore
          .collection('organizations')
          .where('ownerUid', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        organization.value = Organization.fromJson(
            snapshot.docs.first.data() as Map<String, dynamic>);
      } else {
        Get.snackbar('Error', 'Organization profile not found.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load organization profile: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateOrganization(Organization org) async {
    try {
      if (!await _networkService.isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        return;
      }
      await _firestore
          .collection('organizations')
          .doc(org.orgId)
          .update(org.toJson());
      organization.value = org;
      Get.snackbar('Success', 'Profile updated successfully!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: ${e.toString()}');
    }
  }
}
