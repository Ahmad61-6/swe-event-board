import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../routes/app_routes.dart';

class OnboardingController extends GetxController {
  final _storage = GetStorage();
  final RxInt currentPage = 0.obs;

  void onPageChanged(int page) {
    currentPage.value = page;
  }

  void completeOnboarding() {
    _storage.write('isFirstTime', false);
    Get.offAllNamed(AppRoutes.roleSelection);
  }
}
