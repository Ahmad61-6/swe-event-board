import 'dart:async';

import 'package:event_board/constants/app_constants.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../data/services/auth_service.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  final GetStorage _storage = GetStorage();
  final AuthService _authService = Get.find<AuthService>();
  StreamSubscription? _userSubscription;

  @override
  void onReady() {
    super.onReady();
    _initializeApp();
  }

  @override
  void onClose() {
    _userSubscription?.cancel();
    super.onClose();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));

    final bool isFirstTime = _storage.read('isFirstTime') ?? true;

    if (isFirstTime) {
      _storage.write('isFirstTime', false);
      Get.offAllNamed(AppRoutes.onboarding);
    } else {
      _userSubscription = _authService.authStateChanges.listen((user) {
        if (user != null) {
          final role = _storage.read(AppConstants.userRoleKey);
          if (role != null) {
            Get.offAllNamed(AppRoutes.getHomeRoute(role));
          } else {
            Get.offAllNamed(AppRoutes.login);
          }
        } else {
          Get.offAllNamed(AppRoutes.login);
        }
      });
    }
  }
}
