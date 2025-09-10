import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_board/data/services/network_service.dart';
import 'package:get/get.dart';

class AdminDashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NetworkService _networkService = Get.find();

  // System KPIs
  final RxInt totalStudents = 0.obs;
  final RxInt totalOrganizations = 0.obs;
  final RxInt totalEvents = 0.obs;
  final RxInt pendingEvents = 0.obs;
  final RxDouble totalRevenue = 0.0.obs;

  // Loading states
  final RxBool isLoading = true.obs;
  final RxBool isLoadingKPIs = true.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToKPIs();
  }

  void _listenToKPIs() {
    isLoadingKPIs.value = true;
    _networkService.isConnected.then((isConnected) {
      if (!isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        isLoadingKPIs.value = false;
        isLoading.value = false;
        return;
      }

      _firestore.collection('students').snapshots().listen((snapshot) {
        totalStudents.value = snapshot.size;
      });

      _firestore.collection('organizations').snapshots().listen((snapshot) {
        totalOrganizations.value = snapshot.size;
      });

      _firestore.collectionGroup('events').snapshots().listen((snapshot) {
        totalEvents.value = snapshot.size;
        double revenue = 0.0;
        int pending = 0;
        for (var doc in snapshot.docs) {
          final event = doc.data() as Map<String, dynamic>;
          final enrolledCount = event['enrolledCount'] ?? 0;
          final price = (event['price'] ?? 0).toDouble();
          revenue += enrolledCount * price;

          // Count pending events (not approved or rejected)
          final status = event['approvalStatus'] ?? 'pending';
          if (status == 'pending') {
            pending++;
          }
        }
        totalRevenue.value = revenue;
        pendingEvents.value = pending;
      });

      isLoadingKPIs.value = false;
      isLoading.value = false;
    });
  }

  Future<void> refreshData() async {
    // Data is now real-time, so this is not strictly necessary
    // but can be kept for a manual refresh option.
    isLoadingKPIs.value = true;
    await Future.delayed(Duration(milliseconds: 500));
    isLoadingKPIs.value = false;
  }
}
