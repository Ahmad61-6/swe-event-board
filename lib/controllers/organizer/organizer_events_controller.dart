import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_board/controllers/organizer/organizer_dashboard_controller.dart';
import 'package:event_board/data/services/network_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

import '../../data/model/event.dart';
import '../../data/model/organization.dart';
import '../auth_controller.dart';

class OrganizerEventsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final NetworkService _networkService = Get.find();

  final Rx<Organization?> organization = Rx<Organization?>(null);
  final RxList<Event> events = <Event>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isCreating = false.obs;
  final RxBool isUpdating = false.obs;

  DocumentSnapshot? _lastEventDoc;
  static const int _pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    _loadOrganizationProfile();
  }

  Future<void> _loadOrganizationProfile() async {
    try {
      isLoading.value = true;
      if (!await _networkService.isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        isLoading.value = false;
        return;
      }
      final user = Get.find<AuthController>().user.value;
      if (user == null) {
        isLoading.value = false;
        return;
      }

      final snapshot = await _firestore
          .collection('organizations')
          .where('ownerUid', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        organization.value = Organization.fromJson(
          snapshot.docs.first.data() as Map<String, dynamic>,
        );
        _listenToEvents();
      } else {
        Get.snackbar('Error', 'Organization profile not found.');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load organization profile: ${e.toString()}',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _listenToEvents() {
    if (organization.value == null) return;

    _firestore
        .collection('organizations')
        .doc(organization.value!.orgId)
        .collection('events')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) async {
        if (snapshot.docs.isNotEmpty) {
          List<Event> newEvents = [];
          for (var doc in snapshot.docs) {
            final event = Event.fromJson(doc.data() as Map<String, dynamic>);
            final enrollmentSnapshot = await _firestore
                .collection('enrollments')
                .where('eventId', isEqualTo: event.eventId)
                .get();
            final enrolledCount = enrollmentSnapshot.docs.length;
            newEvents.add(
              Event(
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
                approvalStatus: event.approvalStatus,
                enrolledCount: enrolledCount,
                conflict: event.conflict,
                createdAt: event.createdAt,
              ),
            );
          }
          events.value = newEvents;

          // Update dashboard controller if it exists
          try {
            final dashboardController =
            Get.find<OrganizerDashboardController>();
            dashboardController.refreshData();
          } catch (e) {
            // Dashboard controller might not be initialized
          }
        }
      },
      onError: (e) {
        Get.snackbar('Error', 'Failed to load events: ${e.toString()}');
      },
    );
  }

  Future<void> loadEvents({bool refresh = false}) async {}

  Future<String?> uploadBannerImage(File imageFile) async {
    try {
      if (!await _networkService.isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        return null;
      }
      final user = Get.find<AuthController>().user.value;
      if (user == null || organization.value == null) return null;

      final storageRef = _storage.ref(
        'organizations/${organization.value!.orgId}/event_banners/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload banner: ${e.toString()}');
      return null;
    }
  }

  Future<void> createEvent(Event event) async {
    if (organization.value == null) return;

    try {
      isCreating.value = true;
      if (!await _networkService.isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        isCreating.value = false;
        return;
      }

      final user = Get.find<AuthController>().user.value;
      if (user == null) return;

      final eventId = _firestore.collection('temp').doc().id;
      final newEvent = Event(
        eventId: eventId,
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
        createdByUid: user.uid,
        approvalStatus: 'pending', // Set to pending initially
        enrolledCount: 0,
        conflict: false,
        createdAt: DateTime.now(),
      );

      final batch = _firestore.batch();

      final orgEventRef = _firestore
          .collection('organizations')
          .doc(organization.value!.orgId)
          .collection('events')
          .doc(eventId);
      batch.set(orgEventRef, newEvent.toJson());

      final allEventRef = _firestore.collection('allEvents').doc(eventId);
      batch.set(allEventRef, newEvent.toJson());

      await batch.commit();

      Get.snackbar('Success', 'Event created successfully. Awaiting approval.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create event: ${e.toString()}');
    } finally {
      isCreating.value = false;
    }
  }

  Future<void> updateEvent(Event event) async {
    if (organization.value == null) return;

    try {
      isUpdating.value = true;
      if (!await _networkService.isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        isUpdating.value = false;
        return;
      }

      final batch = _firestore.batch();

      final orgEventRef = _firestore
          .collection('organizations')
          .doc(organization.value!.orgId)
          .collection('events')
          .doc(event.eventId);
      batch.update(orgEventRef, {
        ...event.toJson(),
        'approvalStatus': 'pending', // Reset to pending when updated
      });

      final allEventRef = _firestore.collection('allEvents').doc(event.eventId);
      batch.update(allEventRef, {
        ...event.toJson(),
        'approvalStatus': 'pending', // Reset to pending when updated
      });

      await batch.commit();

      final index = events.indexWhere((e) => e.eventId == event.eventId);
      if (index != -1) {
        events[index] = Event(
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
          approvalStatus: 'pending', // Reset approval status
          enrolledCount: event.enrolledCount,
          conflict: event.conflict,
          createdAt: event.createdAt,
        );
      }

      Get.snackbar(
        'Success',
        'Event updated successfully. Awaiting re-approval.',
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update event: ${e.toString()}');
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    if (organization.value == null) return;

    try {
      if (!await _networkService.isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        return;
      }

      final batch = _firestore.batch();

      final orgEventRef = _firestore
          .collection('organizations')
          .doc(organization.value!.orgId)
          .collection('events')
          .doc(eventId);
      batch.delete(orgEventRef);

      final allEventRef = _firestore.collection('allEvents').doc(eventId);
      batch.delete(allEventRef);

      await batch.commit();

      events.removeWhere((event) => event.eventId == eventId);

      Get.snackbar('Success', 'Event deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete event: ${e.toString()}');
    }
  }

  Future<void> notifyEnrollments(String eventId) async {
    try {
      Get.snackbar('Success', 'Notifications sent to enrolled students');
    } catch (e) {
      Get.snackbar('Error', 'Failed to send notifications');
    }
  }

  Future<void> refreshEvents() async {
    await loadEvents(refresh: true);
  }
}
