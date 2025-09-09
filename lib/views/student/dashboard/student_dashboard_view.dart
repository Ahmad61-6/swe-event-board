import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../constants/app_constants.dart';
import '../../../controllers/student/student_dashboard_controller.dart';
import '../../../data/model/event.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/event_card_widget.dart';
import '../../../widgets/organization_card_widget.dart';

class StudentDashboardView extends StatelessWidget {
  final StudentDashboardController controller = Get.put(
    StudentDashboardController(),
  );

  StudentDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.studentSearch),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () => Get.toNamed(AppRoutes.studentNotifications),
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.refreshUpcomingEvents();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carousel Section
                _buildCarouselSection(),

                const SizedBox(height: 24),

                // Category Chips
                _buildCategoryChips(),

                const SizedBox(height: 24),

                // Upcoming Events
                _buildUpcomingEventsSection(),

                const SizedBox(height: 24),

                // Clubs to Join
                _buildClubsToJoinSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselSection() {
    return Obx(() {
      if (controller.isLoadingCarousel.value) {
        return _buildLoadingIndicator();
      }

      if (controller.carouselEvents.isEmpty) {
        return _buildEmptyState('No upcoming events');
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Featured Events',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          CarouselSlider.builder(
            itemCount: controller.carouselEvents.length,
            itemBuilder: (context, index, realIndex) {
              final event = controller.carouselEvents[index];
              return _buildCarouselItem(event);
            },
            options: CarouselOptions(
              height: 200,
              autoPlay: true,
              enlargeCenterPage: true,
              aspectRatio: 16 / 9,
              autoPlayCurve: Curves.fastOutSlowIn,
              enableInfiniteScroll: true,
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              viewportFraction: 0.8,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCarouselItem(Event event) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Banner Image
          event.bannerUrl.isNotEmpty
              ? Image.network(
                  event.bannerUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 50),
                    );
                  },
                )
              : Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 50),
                ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
          ),

          // Event info
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('MMM dd, yyyy').format(event.startAt)} • ${event.venue}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Tap handler
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Get.toNamed(
                '${AppRoutes.eventDetail}?eventId=${event.eventId}',
                arguments: event,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Obx(() {
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: controller.selectedCategory.isEmpty,
                onSelected: (_) => controller.clearCategoryFilter(),
              ),
              ...AppConstants.eventTypes.map((category) {
                return FilterChip(
                  label: Text(category),
                  selected: controller.selectedCategory.value == category,
                  onSelected: (_) => controller.filterByCategory(category),
                );
              }).toList(),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildUpcomingEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming Events',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.studentSearch),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoadingUpcoming.value &&
              controller.upcomingEvents.isEmpty) {
            return _buildLoadingIndicator();
          }

          if (controller.upcomingEvents.isEmpty) {
            return _buildEmptyState('No upcoming events');
          }

          // Filter by category if selected
          List<Event> filteredEvents = controller.upcomingEvents;
          if (controller.selectedCategory.isNotEmpty) {
            filteredEvents = controller.upcomingEvents
                .where(
                  (event) => event.type == controller.selectedCategory.value,
                )
                .toList();
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredEvents.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return EventCardWidget(event: filteredEvents[index]);
            },
          );
        }),
      ],
    );
  }

  Widget _buildClubsToJoinSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Clubs to Join',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoadingClubs.value &&
              controller.clubsToJoin.isEmpty) {
            return _buildLoadingIndicator();
          }

          if (controller.clubsToJoin.isEmpty) {
            return _buildEmptyState('No clubs available');
          }

          return SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.clubsToJoin.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == controller.clubsToJoin.length - 1 ? 0 : 16,
                  ),
                  child: OrganizationCardWidget(
                    organization: controller.clubsToJoin[index],
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
