import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_board/data/services/network_service.dart';
import 'package:flutter/cupertino.dart';
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

  final RxBool isLoading = true.obs;
  final RxBool isLoadingKPIs = true.obs;

  StreamSubscription<QuerySnapshot>? _studentsSubscription;
  StreamSubscription<QuerySnapshot>? _organizationsSubscription;
  StreamSubscription<QuerySnapshot>? _eventsSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenToKPIs();
  }

  @override
  void onClose() {
    _studentsSubscription?.cancel();
    _organizationsSubscription?.cancel();
    _eventsSubscription?.cancel();
    super.onClose();
  }

  void _listenToKPIs() {
    isLoadingKPIs.value = true;
    isLoading.value = true;

    _networkService.isConnected
        .then((isConnected) async {
          if (!isConnected) {
            Get.snackbar(
              'No Internet',
              'Please check your internet connection.',
            );
            isLoadingKPIs.value = false;
            isLoading.value = false;
            return;
          }

          try {
            // Listen to students count - COUNT DOCUMENTS IN STUDENTS COLLECTION
            _studentsSubscription = _firestore
                .collectionGroup('details')
                .where('studentId', isNotEqualTo: null)
                .snapshots()
                .listen(
                  (snapshot) {
                    totalStudents.value = snapshot.docs.length;
                    debugPrint('Total students count: ${snapshot.docs.length}');
                    debugPrint(
                      'Student IDs: ${snapshot.docs.map((doc) => doc.id).toList()}',
                    );
                  },
                  onError: (error) {
                    debugPrint('Error loading students: ${error.toString()}');
                    Get.snackbar(
                      'Error',
                      'Failed to load students count.',
                      backgroundColor: CupertinoColors.systemRed,
                      colorText: CupertinoColors.white,
                    );
                    totalStudents.value = 0;
                  },
                );

            // Listen to organizations count
            _organizationsSubscription = _firestore
                .collection('organizations')
                .snapshots()
                .listen(
                  (snapshot) {
                    totalOrganizations.value = snapshot.docs.length;
                    debugPrint(
                      'Total organizations count: ${snapshot.docs.length}',
                    );
                  },
                  onError: (error) {
                    debugPrint(
                      'Error loading organizations: ${error.toString()}',
                    );
                    Get.snackbar(
                      'Error',
                      'Failed to load organizations count.',
                      backgroundColor: CupertinoColors.systemRed,
                      colorText: CupertinoColors.white,
                    );
                    totalOrganizations.value = 0;
                  },
                );

            // Listen to events with calculations
            _eventsSubscription = _firestore
                .collectionGroup('events')
                .snapshots()
                .listen(
                  (snapshot) {
                    try {
                      totalEvents.value = snapshot.docs.length;
                      double revenue = 0.0;
                      int pending = 0;

                      debugPrint('Total events count: ${snapshot.docs.length}');

                      for (var doc in snapshot.docs) {
                        try {
                          final event = doc.data() as Map<String, dynamic>;
                          final enrolledCount = event['enrolledCount'] ?? 0;
                          final price = (event['price'] ?? 0).toDouble();
                          revenue += enrolledCount * price;

                          final status = event['approvalStatus'] ?? 'pending';
                          if (status == 'pending') {
                            pending++;
                          }
                        } catch (e) {
                          debugPrint(
                            'Error processing event document: ${e.toString()}',
                          );
                        }
                      }

                      totalRevenue.value = revenue;
                      pendingEvents.value = pending;
                      debugPrint('Pending events: $pending, Revenue: $revenue');
                    } catch (error) {
                      debugPrint(
                        'Error processing events data: ${error.toString()}',
                      );
                      Get.snackbar(
                        'Error',
                        'Failed to process events data.',
                        backgroundColor: CupertinoColors.systemRed,
                        colorText: CupertinoColors.white,
                      );
                      totalEvents.value = 0;
                      totalRevenue.value = 0.0;
                      pendingEvents.value = 0;
                    }
                  },
                  onError: (error) {
                    debugPrint('Error loading events: ${error.toString()}');
                    Get.snackbar(
                      'Error',
                      'Failed to load events.',
                      backgroundColor: CupertinoColors.systemRed,
                      colorText: CupertinoColors.white,
                    );
                    totalEvents.value = 0;
                    totalRevenue.value = 0.0;
                    pendingEvents.value = 0;
                  },
                );
          } catch (error) {
            debugPrint('Error initializing dashboard: ${error.toString()}');
            Get.snackbar(
              'Error',
              'Failed to initialize dashboard.',
              backgroundColor: CupertinoColors.systemRed,
              colorText: CupertinoColors.white,
            );
          } finally {
            isLoadingKPIs.value = false;
            isLoading.value = false;
          }
        })
        .catchError((error) {
          debugPrint('Network check failed: ${error.toString()}');
          Get.snackbar(
            'Error',
            'Network check failed.',
            backgroundColor: CupertinoColors.systemRed,
            colorText: CupertinoColors.white,
          );
          isLoadingKPIs.value = false;
          isLoading.value = false;
        });
  }

  Future<void> refreshData() async {
    try {
      isLoadingKPIs.value = true;

      // Cancel existing subscriptions
      _studentsSubscription?.cancel();
      _organizationsSubscription?.cancel();
      _eventsSubscription?.cancel();

      // Reset values temporarily
      totalStudents.value = 0;
      totalOrganizations.value = 0;
      totalEvents.value = 0;
      pendingEvents.value = 0;
      totalRevenue.value = 0.0;

      // Re-initialize listeners
      _listenToKPIs();

      await Future.delayed(const Duration(milliseconds: 500));
    } catch (error) {
      debugPrint('Error refreshing data: ${error.toString()}');
      Get.snackbar(
        'Error',
        'Failed to refresh data.',
        backgroundColor: CupertinoColors.systemRed,
        colorText: CupertinoColors.white,
      );
    } finally {
      isLoadingKPIs.value = false;
    }
  }
}
