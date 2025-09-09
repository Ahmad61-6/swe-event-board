import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:event_board/data/services/network_service.dart';

import '../../data/model/student.dart';
import '../auth_controller.dart';

class StudentProfileController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NetworkService _networkService = Get.find();
  final Rx<Student?> student = Rx<Student?>(null);
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadStudentProfile();
  }

  Future<void> loadStudentProfile() async {
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
          .collection('students')
          .doc(user.uid)
          .collection('details')
          .doc('profile')
          .get();

      if (doc.exists) {
        student.value = Student.fromJson(doc.data()!);
      } else {
        Get.snackbar('Error', 'Student profile not found.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load student profile: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStudent(Student std) async {
    try {
      if (!await _networkService.isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        return;
      }
      await _firestore
          .collection('students')
          .doc(std.uid)
          .collection('details')
          .doc('profile')
          .update(std.toJson());
      student.value = std;
      Get.snackbar('Success', 'Profile updated successfully!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: ${e.toString()}');
    }
  }
}
