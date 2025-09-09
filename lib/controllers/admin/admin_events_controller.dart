import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:event_board/data/services/network_service.dart';

import '../../data/model/event.dart';
import '../../data/model/organization.dart';

class AdminEventsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NetworkService _networkService = Get.find();

  final RxList<Event> events = <Event>[].obs;
  final RxList<Organization> organizations = <Organization>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isUpdating = false.obs;

  DocumentSnapshot? _lastEventDoc;
  static const int _pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    loadOrganizations().then((_) => loadEvents());
  }

  Future<void> loadEvents({bool refresh = false}) async {
    try {
      if (!await _networkService.isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        if (refresh) {
          isLoading.value = false;
        }
        return;
      }
      if (refresh) {
        isLoading.value = true;
        _lastEventDoc = null;
        events.clear();
      }

      Query query = _firestore
          .collectionGroup('events')
          .orderBy('createdAt', descending: true);

      if (_lastEventDoc != null) {
        query = query.startAfterDocument(_lastEventDoc!);
      }

      query = query.limit(_pageSize);

      QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        _lastEventDoc = snapshot.docs.last;

        List<Event> newEvents = snapshot.docs
            .map((doc) => Event.fromJson(doc.data() as Map<String, dynamic>))
            .toList();

        if (refresh) {
          events.value = newEvents;
        } else {
          events.addAll(newEvents);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load events: ${e.toString()}');
    } finally {
      if (refresh) {
        isLoading.value = false;
      }
    }
  }

  Future<void> loadOrganizations() async {
    try {
      if (!await _networkService.isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        return;
      }
      QuerySnapshot snapshot = await _firestore.collection('organizations').get();
      organizations.value = snapshot.docs
          .map((doc) => Organization.fromJson(doc.data() as Map<String, dynamic>))
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
          .update({'approved': approve});

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
        approved: approve,
        enrolledCount: event.enrolledCount,
        conflict: event.conflict,
        createdAt: event.createdAt,
      );

      Get.snackbar('Success', approve ? 'Event approved' : 'Event rejected');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update event approval: ${e.toString()}');
    } finally {
      isUpdating.value = false;
    }
  }

  Organization? getOrganizationForEvent(Event event) {
    return organizations.firstWhereOrNull((org) => org.ownerUid == event.createdByUid);
  }

  Future<void> refreshEvents() async {
    await loadEvents(refresh: true);
  }
}
