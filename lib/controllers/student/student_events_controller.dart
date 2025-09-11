import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/model/event.dart';
import '../../data/services/network_service.dart';

class StudentEventsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NetworkService _networkService = Get.find();

  final RxList<Event> carouselEvents = <Event>[].obs;
  final RxList<Event> upcomingEvents = <Event>[].obs;
  final RxList<Event> allEvents = <Event>[].obs;
  final RxBool isLoadingCarousel = true.obs;
  final RxBool isLoadingUpcoming = true.obs;
  final RxBool isLoadingAll = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCarouselEvents();
    fetchUpcomingEvents();
  }

  Future<void> fetchCarouselEvents() async {
    try {
      isLoadingCarousel.value = true;
      if (!await _networkService.isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        return;
      }

      debugPrint('🔄 Fetching all approved events for carousel...');

      // Get all approved events first
      final snapshot = await _firestore
          .collection('allEvents')
          .where('approvalStatus', isEqualTo: 'approved')
          .get();

      debugPrint('✅ Retrieved ${snapshot.docs.length} approved events');

      // Filter and sort locally
      final now = DateTime.now();
      final approvedEvents = snapshot.docs
          .map((doc) => Event.fromJson(doc.data() as Map<String, dynamic>))
          .where((event) => event.startAt.isAfter(now)) // Only future events
          .toList();

      debugPrint('📅 Filtered to ${approvedEvents.length} upcoming events');

      // Sort by start date (ascending - soonest first)
      approvedEvents.sort((a, b) => a.startAt.compareTo(b.startAt));

      // Get last 5 events (most recent ones)
      final lastFiveEvents = approvedEvents.take(5).toList();

      debugPrint('🎠 Carousel events: ${lastFiveEvents.length} events');
      for (var event in lastFiveEvents) {
        debugPrint(
          '   - ${event.title} (${DateFormat('MMM dd').format(event.startAt)})',
        );
      }

      carouselEvents.value = lastFiveEvents;
    } catch (e) {
      debugPrint('❌ Error fetching carousel events: ${e.toString()}');
      Get.snackbar(
        'Error',
        'Failed to load featured events: ${e.toString()}',
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingCarousel.value = false;
    }
  }

  Future<void> fetchUpcomingEvents() async {
    try {
      isLoadingUpcoming.value = true;
      if (!await _networkService.isConnected) {
        return;
      }

      debugPrint('🔄 Fetching all approved events for upcoming...');

      // Get all approved events first
      final snapshot = await _firestore
          .collection('allEvents')
          .where('approvalStatus', isEqualTo: 'approved')
          .get();

      debugPrint('✅ Retrieved ${snapshot.docs.length} approved events');

      // Filter and sort locally
      final now = DateTime.now();
      final approvedEvents = snapshot.docs
          .map((doc) => Event.fromJson(doc.data() as Map<String, dynamic>))
          .where((event) => event.startAt.isAfter(now)) // Only future events
          .toList();

      debugPrint('📅 Filtered to ${approvedEvents.length} upcoming events');

      // Sort by start date (ascending - soonest first)
      approvedEvents.sort((a, b) => a.startAt.compareTo(b.startAt));

      // Get last 3 events (most recent ones)
      final lastThreeEvents = approvedEvents.take(3).toList();

      debugPrint('📋 Upcoming events: ${lastThreeEvents.length} events');
      for (var event in lastThreeEvents) {
        debugPrint(
          '   - ${event.title} (${DateFormat('MMM dd').format(event.startAt)})',
        );
      }

      upcomingEvents.value = lastThreeEvents;
    } catch (e) {
      debugPrint('❌ Error fetching upcoming events: ${e.toString()}');
      Get.snackbar(
        'Error',
        'Failed to load upcoming events: ${e.toString()}',
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingUpcoming.value = false;
    }
  }

  Future<void> fetchAllEvents() async {
    try {
      isLoadingAll.value = true;
      if (!await _networkService.isConnected) {
        return;
      }

      debugPrint('🔄 Fetching all approved events...');

      final snapshot = await _firestore
          .collection('allEvents')
          .where('approvalStatus', isEqualTo: 'approved')
          .get();

      debugPrint('✅ Retrieved ${snapshot.docs.length} approved events');

      // Filter for upcoming events and sort
      final now = DateTime.now();
      allEvents.value =
          snapshot.docs
              .map((doc) => Event.fromJson(doc.data() as Map<String, dynamic>))
              .where((event) => event.startAt.isAfter(now))
              .toList()
            ..sort((a, b) => a.startAt.compareTo(b.startAt));

      debugPrint('📊 All upcoming events: ${allEvents.length} events');
    } catch (e) {
      debugPrint('❌ Error fetching all events: ${e.toString()}');
      Get.snackbar(
        'Error',
        'Failed to load events: ${e.toString()}',
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingAll.value = false;
    }
  }

  Future<List<Event>> searchEvents(String query) async {
    try {
      if (!await _networkService.isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        return [];
      }

      debugPrint('🔍 Searching events for: "$query"');

      final snapshot = await _firestore
          .collection('allEvents')
          .where('approvalStatus', isEqualTo: 'approved')
          .get();

      final now = DateTime.now();
      final searchTerm = query.toLowerCase();

      final results =
          snapshot.docs
              .map((doc) => Event.fromJson(doc.data() as Map<String, dynamic>))
              .where((event) => event.startAt.isAfter(now))
              .where((event) {
                return event.title.toLowerCase().contains(searchTerm) ||
                    event.description.toLowerCase().contains(searchTerm) ||
                    event.type.toLowerCase().contains(searchTerm) ||
                    event.venue.toLowerCase().contains(searchTerm);
              })
              .toList()
            ..sort((a, b) => a.startAt.compareTo(b.startAt));

      debugPrint('🔍 Search found ${results.length} results for "$query"');

      return results;
    } catch (e) {
      debugPrint('❌ Error searching events: ${e.toString()}');
      Get.snackbar(
        'Error',
        'Failed to search events: ${e.toString()}',
        duration: const Duration(seconds: 3),
      );
      return [];
    }
  }

  // Refresh methods with debug logs
  Future<void> refreshCarousel() async {
    debugPrint('🔄 Refreshing carousel events...');
    await fetchCarouselEvents();
  }

  Future<void> refreshUpcoming() async {
    debugPrint('🔄 Refreshing upcoming events...');
    await fetchUpcomingEvents();
  }

  Future<void> refreshAll() async {
    debugPrint('🔄 Refreshing all events...');
    await fetchAllEvents();
  }

  // Helper method to get events using for loop (as requested)
  List<Event> getLastNEvents(List<Event> events, int count) {
    final List<Event> result = [];
    final int startIndex = events.length > count ? events.length - count : 0;

    for (int i = startIndex; i < events.length; i++) {
      result.add(events[i]);
    }

    return result;
  }

  // Alternative implementation using for loops
  Future<void> fetchEventsWithForLoops() async {
    try {
      debugPrint('🔄 Fetching events using for loop implementation...');

      final snapshot = await _firestore
          .collection('allEvents')
          .where('approvalStatus', isEqualTo: 'approved')
          .get();

      final now = DateTime.now();
      final List<Event> approvedEvents = [];
      final List<Event> upcomingEventsList = [];
      final List<Event> carouselEventsList = [];

      // First for loop: Convert documents to Event objects
      for (var doc in snapshot.docs) {
        try {
          final event = Event.fromJson(doc.data() as Map<String, dynamic>);
          approvedEvents.add(event);
        } catch (e) {
          debugPrint('⚠️ Error parsing event document: $e');
        }
      }

      debugPrint('✅ Converted ${approvedEvents.length} events');

      // Second for loop: Filter for upcoming events
      for (var event in approvedEvents) {
        if (event.startAt.isAfter(now)) {
          upcomingEventsList.add(event);
        }
      }

      debugPrint('📅 Found ${upcomingEventsList.length} upcoming events');

      // Third for loop: Sort by start date
      for (int i = 0; i < upcomingEventsList.length - 1; i++) {
        for (int j = i + 1; j < upcomingEventsList.length; j++) {
          if (upcomingEventsList[i].startAt.isAfter(
            upcomingEventsList[j].startAt,
          )) {
            final temp = upcomingEventsList[i];
            upcomingEventsList[i] = upcomingEventsList[j];
            upcomingEventsList[j] = temp;
          }
        }
      }

      // Fourth for loop: Get last 5 for carousel
      final carouselCount = upcomingEventsList.length > 5
          ? 5
          : upcomingEventsList.length;
      for (int i = 0; i < carouselCount; i++) {
        carouselEventsList.add(upcomingEventsList[i]);
      }

      debugPrint('🎠 Carousel events: ${carouselEventsList.length} events');

      carouselEvents.value = carouselEventsList;
      upcomingEvents.value = upcomingEventsList.take(3).toList();
      allEvents.value = upcomingEventsList;
    } catch (e) {
      debugPrint('❌ Error in for loop implementation: ${e.toString()}');
    }
  }
}
