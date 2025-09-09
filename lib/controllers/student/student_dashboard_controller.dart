import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_board/data/services/network_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../data/model/event.dart';
import '../../data/model/organization.dart';

class StudentDashboardController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NetworkService _networkService = Get.find();

  // Carousel events (recent approved events)
  final RxList<Event> carouselEvents = <Event>[].obs;

  // Upcoming events
  final RxList<Event> upcomingEvents = <Event>[].obs;

  // Clubs to join
  final RxList<Organization> clubsToJoin = <Organization>[].obs;

  // Loading states
  final RxBool isLoadingCarousel = true.obs;
  final RxBool isLoadingUpcoming = true.obs;
  final RxBool isLoadingClubs = true.obs;

  // Selected category filter
  final RxString selectedCategory = ''.obs;

  // Pagination
  DocumentSnapshot? _lastUpcomingEventDoc;
  static const int _pageSize = 10;

  @override
  void onInit() {
    super.onInit();
    _loadCarouselEvents();
    _loadUpcomingEvents();
    _loadClubsToJoin();
  }

  Future<void> _loadCarouselEvents() async {
    try {
      isLoadingCarousel.value = true;
      if (!await _networkService.isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        isLoadingCarousel.value = false;
        return;
      }

      // Get recent approved events from all organizations
      QuerySnapshot snapshot = await _firestore
          .collectionGroup('events')
          .where('approved', isEqualTo: true)
          .where('startAt', isGreaterThan: Timestamp.now())
          .orderBy('startAt')
          .limit(5)
          .get();

      carouselEvents.value = snapshot.docs
          .map((doc) => Event.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint(e.toString());
      Get.snackbar('Error', 'Failed to load carousel events');
    } finally {
      isLoadingCarousel.value = false;
    }
  }

  Future<void> _loadUpcomingEvents({bool refresh = false}) async {
    try {
      if (!await _networkService.isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        if (refresh) {
          isLoadingUpcoming.value = false;
        }
        return;
      }
      if (refresh) {
        isLoadingUpcoming.value = true;
        _lastUpcomingEventDoc = null;
        upcomingEvents.clear();
      }

      Query query = _firestore
          .collectionGroup('events')
          .where('approved', isEqualTo: true)
          .where('startAt', isGreaterThan: Timestamp.now())
          .orderBy('startAt');

      if (_lastUpcomingEventDoc != null) {
        query = query.startAfterDocument(_lastUpcomingEventDoc!);
      }

      query = query.limit(_pageSize);

      QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        _lastUpcomingEventDoc = snapshot.docs.last;

        List<Event> newEvents = snapshot.docs
            .map((doc) => Event.fromJson(doc.data() as Map<String, dynamic>))
            .toList();

        if (refresh) {
          upcomingEvents.value = newEvents;
        } else {
          upcomingEvents.addAll(newEvents);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load upcoming events');
      debugPrint(e.toString());
    } finally {
      if (refresh) {
        isLoadingUpcoming.value = false;
      }
    }
  }

  Future<void> loadMoreUpcomingEvents() async {
    if (_lastUpcomingEventDoc == null) return;
    await _loadUpcomingEvents();
  }

  Future<void> refreshUpcomingEvents() async {
    await _loadUpcomingEvents(refresh: true);
  }

  Future<void> _loadClubsToJoin() async {
    try {
      isLoadingClubs.value = true;
      if (!await _networkService.isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        isLoadingClubs.value = false;
        return;
      }

      QuerySnapshot snapshot = await _firestore
          .collection('organizations')
          .where('approved', isEqualTo: true)
          .limit(10)
          .get();

      clubsToJoin.value = snapshot.docs
          .map(
            (doc) => Organization.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load clubs');
    } finally {
      isLoadingClubs.value = false;
    }
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
    // Filtering would be implemented on the UI side for better performance
  }

  void clearCategoryFilter() {
    selectedCategory.value = '';
  }
}
