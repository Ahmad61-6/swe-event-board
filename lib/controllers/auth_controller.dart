import 'dart:io';

import 'package:event_board/data/services/network_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../constants/app_constants.dart';
import '../data/services/auth_service.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find();
  final GetStorage _storage = GetStorage();
  final NetworkService _networkService = Get.find();

  Rx<User?> user = Rx<User?>(null);
  RxBool isLoading = false.obs;
  RxString role = ''.obs;
  RxBool isPasswordVisible = false.obs; // Add this line

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_authService.authStateChanges);

    // Load cached role
    String? cachedRole = _storage.read(AppConstants.userRoleKey);
    if (cachedRole != null) {
      role.value = cachedRole;
    }
  }

  // Add this method to toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      isLoading.value = true;
      if (!await _networkService.isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        isLoading.value = false;
        return;
      }
      final userData = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userData != null) {
        role.value = userData['role'];
        Get.offAllNamed(AppRoutes.getHomeRoute(userData['role']));
      }
    } catch (e) {
      debugPrint('=====>Error during sign in: ${e.toString()}');
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUpStudent({
    required String email,
    required String password,
    required String fullName,
    required String studentId,
    required String batch,
    required List<String> interests,
    File? image,
  }) async {
    try {
      isLoading.value = true;
      if (!await _networkService.isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        isLoading.value = false;
        return;
      }
      final userData = await _authService.signUpStudent(
        email: email,
        password: password,
        fullName: fullName,
        studentId: studentId,
        batch: batch,
        interests: interests,
        image: image,
      );

      if (userData != null) {
        role.value = userData['role'];
        Get.offAllNamed(AppRoutes.studentDashboard);
      }
    } catch (e) {
      debugPrint('Error during student sign up: ${e.toString()}');
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUpOrganizer({
    required String email,
    required String password,
    required String fullName,
    required String organizationName,
    required String organizationType,
    required String contactPhone,
    File? image,
  }) async {
    try {
      isLoading.value = true;
      if (!await _networkService.isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        isLoading.value = false;
        return;
      }
      final userData = await _authService.signUpOrganizer(
        email: email,
        password: password,
        fullName: fullName,
        organizationName: organizationName,
        organizationType: organizationType,
        contactPhone: contactPhone,
        image: image,
      );

      if (userData != null) {
        role.value = userData['role'];
        Get.offAllNamed(AppRoutes.organizerDashboard);
      }
    } catch (e) {
      debugPrint('Error during organizer sign up: ${e.toString()}');
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUpAdmin({
    required String email,
    required String password,
    required String adminCode,
  }) async {
    try {
      isLoading.value = true;
      if (!await _networkService.isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        isLoading.value = false;
        return;
      }
      final userData = await _authService.signUpAdmin(
        email: email,
        password: password,
        adminCode: adminCode,
      );

      if (userData != null) {
        role.value = userData['role'];
        Get.offAllNamed(AppRoutes.adminDashboard);
      }
    } catch (e) {
      debugPrint('Error during admin sign up: ${e.toString()}');
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    if (!await _networkService.isConnected) {
      Get.snackbar('No Internet', 'Please check your internet connection.');
      return;
    }
    await _authService.signOut();
    role.value = '';
    Get.offAllNamed(AppRoutes.login);
  }

  String? getCachedRole() {
    return _storage.read(AppConstants.userRoleKey);
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      isLoading.value = true;
      if (!await _networkService.isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        isLoading.value = false;
        return;
      }
      await _authService.sendPasswordResetEmail(email: email);
      Get.snackbar(
        'Success',
        'Password reset link sent to your email.',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      debugPrint('=====>Error during password reset: ${e.toString()}');
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
