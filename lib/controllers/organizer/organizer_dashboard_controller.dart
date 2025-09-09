import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../data/model/event.dart';
import '../../data/model/organization.dart';
import '../auth_controller.dart';

class OrganizerDashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Organization profile
  Rx<Organization?> organization = Rx<Organization?>(null);

  // KPIs
  final RxInt totalEvents = 0.obs;
  final RxInt totalEnrollments = 0.obs;
  final RxDouble totalRevenue = 0.0.obs;
  final RxList<Event> recentEvents = <Event>[].obs;

  // Loading states
  final RxBool isLoading = true.obs;
  final RxBool isLoadingKPIs = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadOrganizationProfile();
  }

  Future<void> _loadOrganizationProfile() async {
    try {
      final user = Get.find<AuthController>().user.value;
      if (user == null) return;

      QuerySnapshot snapshot = await _firestore
          .collection('organizations')
          .where('ownerUid', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        organization.value = Organization.fromJson(
          snapshot.docs.first.data() as Map<String, dynamic>,
        );
        // After loading profile, load other data
        _loadKPIs();
        _loadRecentEvents();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load organization profile');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadKPIs() async {
    try {
      isLoadingKPIs.value = true;

      if (organization.value == null) return;

      // Load total events
      QuerySnapshot eventsSnapshot = await _firestore
          .collection('organizations')
          .doc(organization.value!.orgId)
          .collection('events')
          .get();

      totalEvents.value = eventsSnapshot.size;

      // Calculate total enrollments and revenue
      int enrollmentsCount = 0;
      double revenue = 0.0;

      for (var doc in eventsSnapshot.docs) {
        final event = Event.fromJson(doc.data() as Map<String, dynamic>);
        enrollmentsCount += event.enrolledCount;
        revenue += event.enrolledCount * event.price;
      }

      totalEnrollments.value = enrollmentsCount;
      totalRevenue.value = revenue;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load KPIs');
    } finally {
      isLoadingKPIs.value = false;
    }
  }

  Future<void> _loadRecentEvents() async {
    try {
      if (organization.value == null) return;

      QuerySnapshot snapshot = await _firestore
          .collection('organizations')
          .doc(organization.value!.orgId)
          .collection('events')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      recentEvents.value = snapshot.docs
          .map((doc) => Event.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load recent events');
    }
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    await _loadOrganizationProfile();
  }
}