import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:event_board/data/services/network_service.dart';

import '../../data/model/event.dart';

class StudentSearchController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NetworkService _networkService = Get.find();

  final RxList<Event> searchResults = <Event>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasSearched = false.obs;

  static const int _pageSize = 10;

  Future<void> searchEvents(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      hasSearched.value = false;
      return;
    }

    try {
      isLoading.value = true;
      hasSearched.value = true;
      if (!await _networkService.isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection.');
        isLoading.value = false;
        return;
      }

      // Simple search implementation - in production, you'd use Firestore indexes
      QuerySnapshot snapshot = await _firestore
          .collectionGroup('events')
          .where('approved', isEqualTo: true)
          .get();

      List<Event> allEvents = snapshot.docs
          .map((doc) => Event.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Filter locally (not efficient for large datasets)
      searchResults.value = allEvents
          .where(
            (event) =>
                event.title.toLowerCase().contains(query.toLowerCase()) ||
                event.description.toLowerCase().contains(query.toLowerCase()) ||
                event.type.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Search failed');
    } finally {
      isLoading.value = false;
    }
  }
}
