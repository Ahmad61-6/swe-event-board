import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_board/data/services/network_service.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../data/model/event.dart';

class StudentSearchController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NetworkService _networkService = Get.find();

  final RxList<Event> searchResults = <Event>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasSearched = false.obs;
  final RxString lastQuery = ''.obs;

  static const int _pageSize = 20;

  Future<void> searchEvents(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      hasSearched.value = false;
      lastQuery.value = '';
      return;
    }

    // Don't search again if same query
    if (lastQuery.value == query && hasSearched.value) {
      return;
    }

    try {
      isLoading.value = true;
      hasSearched.value = true;
      lastQuery.value = query;

      if (!await _networkService.isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        isLoading.value = false;
        return;
      }

      // Convert query to lowercase for case-insensitive search
      final searchQuery = query.toLowerCase();

      // Get all events first
      QuerySnapshot snapshot = await _firestore
          .collection('allEvents')
          .where('approved', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      List<Event> allEvents = snapshot.docs
          .map((doc) => Event.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Filter events locally for better search functionality
      List<Event> filteredEvents = [];
      for (var event in allEvents) {
        if (_matchesSearchQuery(event, searchQuery)) {
          filteredEvents.add(event);
        }
      }

      searchResults.value = filteredEvents.take(_pageSize).toList();
    } catch (e) {
      Get.snackbar('Error', 'Search failed: ${e.toString()}');
      searchResults.clear();
    } finally {
      isLoading.value = false;
    }
  }

  bool _matchesSearchQuery(Event event, String query) {
    final searchTerms = query
        .split(' ')
        .where((term) => term.isNotEmpty)
        .toList();

    if (searchTerms.isEmpty) return false;

    // Check each search term against event fields
    for (final term in searchTerms) {
      final matches =
          event.title.toLowerCase().contains(term) ||
          event.description.toLowerCase().contains(term) ||
          event.type.toLowerCase().contains(term) ||
          event.venue.toLowerCase().contains(term) ||
          _matchesDate(event, term);

      if (!matches) return false;
    }

    return true;
  }

  bool _matchesDate(Event event, String term) {
    try {
      // Try to parse date formats
      final dateFormats = [
        'MMM dd, yyyy', //full date
        'MMM dd', // only day
        'MMMM dd', // only month
        'yyyy', // yeat
        'MM', // 01 (month)
        'dd', // 01 (day)
      ];

      for (final format in dateFormats) {
        final formattedDate = DateFormat(
          format,
        ).format(event.startAt).toLowerCase();
        if (formattedDate.contains(term)) {
          return true;
        }
      }

      // Check day names
      final dayName = DateFormat('EEEE').format(event.startAt).toLowerCase();
      if (dayName.contains(term)) {
        return true;
      }

      // Check month names
      final monthName = DateFormat('MMMM').format(event.startAt).toLowerCase();
      if (monthName.contains(term)) {
        return true;
      }
    } catch (e) {
      print('Error parsing date: $e');
      // If date parsing fails, continue with other search criteria
    }

    return false;
  }

  // FIXED: Removed _searchController reference from controller
  void clearSearch() {
    searchResults.clear();
    hasSearched.value = false;
    lastQuery.value = '';
  }

  // For advanced search with filters
  Future<void> searchWithFilters({
    required String query,
    String? type,
    double? minPrice,
    double? maxPrice,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      isLoading.value = true;

      // Get all events first
      QuerySnapshot snapshot = await _firestore
          .collection('allEvents')
          .where('approved', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      List<Event> allEvents = snapshot.docs
          .map((doc) => Event.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Filter locally
      List<Event> filteredEvents = [];
      for (var event in allEvents) {
        bool matches = true;

        // Apply filters
        if (type != null && type.isNotEmpty && event.type != type) {
          matches = false;
        }

        if (minPrice != null && event.price < minPrice) {
          matches = false;
        }

        if (maxPrice != null && event.price > maxPrice) {
          matches = false;
        }

        if (startDate != null && event.startAt.isBefore(startDate)) {
          matches = false;
        }

        if (endDate != null && event.startAt.isAfter(endDate)) {
          matches = false;
        }

        if (query.isNotEmpty && !_matchesSearchQuery(event, query.toLowerCase())) {
          matches = false;
        }

        if (matches) {
          filteredEvents.add(event);
        }
      }

      searchResults.value = filteredEvents.take(_pageSize).toList();
      hasSearched.value = true;
      lastQuery.value = query;
    } catch (e) {
      Get.snackbar('Error', 'Search with filters failed: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}