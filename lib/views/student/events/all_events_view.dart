import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/student/student_events_controller.dart';
import '../../../widgets/event_card_widget.dart';
import '../event/event_detail_view.dart';

class AllEventsView extends StatelessWidget {
  final StudentEventsController controller = Get.find<StudentEventsController>();

  AllEventsView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.fetchAllEvents(); // Fetch all events when the view is built

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Events'),
      ),
      body: Obx(() {
        if (controller.isLoadingAll.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.allEvents.isEmpty) {
          return const Center(
            child: Text('No events found.'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.allEvents.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final event = controller.allEvents[index];
            return GestureDetector(
              onTap: () => Get.to(() => EventDetailView(event: event)),
              child: EventCardWidget(event: event),
            );
          },
        );
      }),
    );
  }
}
