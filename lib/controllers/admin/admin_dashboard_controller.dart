import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_board/data/services/network_service.dart';
import 'package:flutter/material.dart';
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
    _loadKPIs();
  }

  Future<void> _loadKPIs() async {
    try {
      isLoadingKPIs.value = true;
      if (!await _networkService.isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        isLoadingKPIs.value = false;
        isLoading.value = false;
        return;
      }

      // Load total students
      QuerySnapshot studentsSnapshot = await _firestore
          .collection('students')
          .get();
      totalStudents.value = studentsSnapshot.size;

      // Load total organizations
      QuerySnapshot orgSnapshot = await _firestore
          .collection('organizations')
          .get();
      totalOrganizations.value = orgSnapshot.size;

      // Load events and pending events
      QuerySnapshot allEventsSnapshot = await _firestore
          .collectionGroup('events')
          .get();

      totalEvents.value = allEventsSnapshot.size;

      QuerySnapshot pendingEventsSnapshot = await _firestore
          .collectionGroup('events')
          .where('approved', isEqualTo: false)
          .get();

      pendingEvents.value = pendingEventsSnapshot.size;

      // Calculate total revenue (simplified)
      double revenue = 0.0;
      for (var doc in allEventsSnapshot.docs) {
        final event = doc.data() as Map<String, dynamic>;
        final enrolledCount = event['enrolledCount'] ?? 0;
        final price = (event['price'] ?? 0).toDouble();
        revenue += enrolledCount * price;
      }

      totalRevenue.value = revenue;
    } catch (e) {
      debugPrint(e.toString());
      Get.snackbar('Error', 'Failed to load KPIs');
    } finally {
      isLoadingKPIs.value = false;
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await _loadKPIs();
  }
}
