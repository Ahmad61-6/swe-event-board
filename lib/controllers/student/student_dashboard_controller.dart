import 'package:event_board/data/static_data.dart';
import 'package:get/get.dart';

import '../../data/model/event.dart';
import '../../data/model/organization.dart';

class StudentDashboardController extends GetxController {
  // Carousel events (recent approved events)
  final RxList<Event> carouselEvents = <Event>[].obs;

  // Upcoming events
  final RxList<Event> upcomingEvents = <Event>[].obs;

  // Clubs to join
  final RxList<Organization> clubsToJoin = <Organization>[].obs;

  // Selected category filter
  final RxString selectedCategory = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  void _loadData() {
    carouselEvents.value = StaticData.events;
    upcomingEvents.value = StaticData.events;
    clubsToJoin.value = StaticData.organizations;
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
  }

  void clearCategoryFilter() {
    selectedCategory.value = '';
  }
}