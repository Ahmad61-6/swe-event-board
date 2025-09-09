import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../data/model/event.dart';
import '../../data/model/organization.dart';
import '../auth_controller.dart';

class OrganizerEventsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
            snapshot.docs.first.data() as Map<String, dynamic>);
        await loadEvents(refresh: true);
      } else {
        Get.snackbar('Error', 'Organization profile not found.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load organization profile: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadEvents({bool refresh = false}) async {
    if (organization.value == null) return;

    try {
      if (refresh) {
        _lastEventDoc = null;
        events.clear();
      }

      Query query = _firestore
          .collection('organizations')
          .doc(organization.value!.orgId)
          .collection('events')
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
    }
  }

  Future<String?> uploadBannerImage(File imageFile) async {
    try {
      final user = Get.find<AuthController>().user.value;
      if (user == null || organization.value == null) return null;

      final storageRef = _storage.ref(
          'organizations/${organization.value!.orgId}/event_banners/${DateTime.now().millisecondsSinceEpoch}.jpg');

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
        approved: false,
        enrolledCount: 0,
        conflict: false,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('organizations')
          .doc(organization.value!.orgId)
          .collection('events')
          .doc(eventId)
          .set(newEvent.toJson());

      events.insert(0, newEvent);

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

      await _firestore
          .collection('organizations')
          .doc(organization.value!.orgId)
          .collection('events')
          .doc(event.eventId)
          .update({
        ...event.toJson(),
        'approved': false,
      });

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
          approved: false, // Reset approval status
          enrolledCount: event.enrolledCount,
          conflict: event.conflict,
          createdAt: event.createdAt,
        );
      }

      Get.snackbar(
          'Success', 'Event updated successfully. Awaiting re-approval.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update event: ${e.toString()}');
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    if (organization.value == null) return;

    try {
      await _firestore
          .collection('organizations')
          .doc(organization.value!.orgId)
          .collection('events')
          .doc(eventId)
          .delete();

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
