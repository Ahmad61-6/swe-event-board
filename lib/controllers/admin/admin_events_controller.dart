import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_board/controllers/admin/admin_dashboard_controller.dart';
import 'package:event_board/data/services/network_service.dart';
import 'package:get/get.dart';

import '../../data/model/event.dart';
import '../../data/model/organization.dart';

class AdminEventsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NetworkService _networkService = Get.find();

  final RxList<Event> events = <Event>[].obs;
  final RxList<Organization> organizations = <Organization>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isUpdating = false.obs;
  final RxBool showPendingOnly = false.obs;

  DocumentSnapshot? _lastEventDoc;
  static const int _pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    loadOrganizations().then((_) => _listenToEvents());
  }

  void _listenToEvents() {
    isLoading.value = true;
    _networkService.isConnected.then((isConnected) {
      if (!isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        isLoading.value = false;
        return;
      }

      _firestore
          .collectionGroup('events')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen(
            (snapshot) {
              if (snapshot.docs.isNotEmpty) {
                List<Event> newEvents = snapshot.docs
                    .map(
                      (doc) =>
                          Event.fromJson(doc.data() as Map<String, dynamic>),
                    )
                    .toList();
                events.value = newEvents;
              }
              isLoading.value = false;
            },
            onError: (e) {
              Get.snackbar('Error', 'Failed to load events: ${e.toString()}');
              isLoading.value = false;
            },
          );
    });
  }

  Future<void> loadEvents({bool refresh = false}) async {
    // This function is no longer needed as we are using a stream.
    // You can keep it for pagination if you want to implement it later.
  }

  Future<void> loadOrganizations() async {
    try {
      if (!await _networkService.isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        return;
      }
      QuerySnapshot snapshot = await _firestore
          .collection('organizations')
          .get();
      organizations.value = snapshot.docs
          .map(
            (doc) => Organization.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load organizations: ${e.toString()}');
    }
  }

  Future<void> approveEvent(String eventId, bool approve) async {
    try {
      isUpdating.value = true;
      if (!await _networkService.isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        isUpdating.value = false;
        return;
      }

      final eventIndex = events.indexWhere((e) => e.eventId == eventId);
      if (eventIndex == -1) {
        isUpdating.value = false;
        return;
      }

      final event = events[eventIndex];
      final org = getOrganizationForEvent(event);

      if (org == null) {
        Get.snackbar('Error', 'Could not find organization for this event.');
        isUpdating.value = false;
        return;
      }

      // Update approval status
      final newStatus = approve ? 'approved' : 'rejected';
      await _firestore
          .collection('organizations')
          .doc(org.orgId)
          .collection('events')
          .doc(eventId)
          .update({'approvalStatus': newStatus});

      // Update local state
      events[eventIndex] = Event(
        eventId: event.eventId,
        title: event.title,
        description: event.description,
        type: event.type,
        bannerUrl: event.bannerUrl,
        startAt: event.startAt,
        endAt: event.endAt,
        venue: event.venue,
        meetLink: event.meetLink,
        price: event.price,
        capacity: event.capacity,
        createdByUid: event.createdByUid,
        approvalStatus: newStatus,
        enrolledCount: event.enrolledCount,
        conflict: event.conflict,
        createdAt: event.createdAt,
      );

      // Refresh dashboard to update pending count
      try {
        final dashboardController = Get.find<AdminDashboardController>();
        dashboardController.refreshData();
      } catch (e) {
        // Dashboard controller might not be initialized
      }

      Get.snackbar('Success', approve ? 'Event approved' : 'Event rejected');
      isUpdating.value = false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update event approval: ${e.toString()}');
      isUpdating.value = false;
    }
  }

  Future<void> setEventToPending(String eventId) async {
    try {
      final eventIndex = events.indexWhere((e) => e.eventId == eventId);
      if (eventIndex == -1) return;

      final event = events[eventIndex];
      final org = getOrganizationForEvent(event);

      if (org == null) {
        Get.snackbar('Error', 'Could not find organization for this event.');
        return;
      }

      await _firestore
          .collection('organizations')
          .doc(org.orgId)
          .collection('events')
          .doc(eventId)
          .update({'approvalStatus': 'pending'});

      // Update local state
      events[eventIndex] = Event(
        eventId: event.eventId,
        title: event.title,
        description: event.description,
        type: event.type,
        bannerUrl: event.bannerUrl,
        startAt: event.startAt,
        endAt: event.endAt,
        venue: event.venue,
        meetLink: event.meetLink,
        price: event.price,
        capacity: event.capacity,
        createdByUid: event.createdByUid,
        approvalStatus: 'pending',
        enrolledCount: event.enrolledCount,
        conflict: event.conflict,
        createdAt: event.createdAt,
      );

      // Refresh dashboard to update pending count
      try {
        final dashboardController = Get.find<AdminDashboardController>();
        dashboardController.refreshData();
      } catch (e) {
        // Dashboard controller might not be initialized
      }

      Get.snackbar('Success', 'Event status set to pending');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update event status: ${e.toString()}');
    }
  }

  Organization? getOrganizationForEvent(Event event) {
    return organizations.firstWhereOrNull(
      (org) => org.ownerUid == event.createdByUid,
    );
  }

  Future<void> refreshEvents() async {
    await loadEvents(refresh: true);
  }
}
