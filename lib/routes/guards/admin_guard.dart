import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../constants/app_constants.dart';

class AdminGuard extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final storage = GetStorage();
    final role = storage.read(AppConstants.userRoleKey);

    if (role != AppConstants.roleAdmin) {
      return const RouteSettings(name: '/unauthorized');
    }
    return null;
  }
}
