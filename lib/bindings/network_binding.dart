import 'package:event_board/data/services/network_service.dart';
import 'package:event_board/data/services/storage_service.dart';
import 'package:get/get.dart';

class NetworkBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<StorageService>(StorageService(), permanent: true);
    Get.put<NetworkService>(NetworkService(), permanent: true);
  }
}
