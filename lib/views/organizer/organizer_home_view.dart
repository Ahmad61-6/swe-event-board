import 'package:flutter/material.dart';

import 'dashboard/organizer_dashboard_view.dart';
import 'events/organizer_events_view.dart';
import 'merchandise/organizer_merchandise_view.dart';
import 'notifications/organizer_notifications_view.dart';
import 'profile/organizer_profile_view.dart';

class OrganizerHomeView extends StatefulWidget {
  const OrganizerHomeView({Key? key}) : super(key: key);

  @override
  State<OrganizerHomeView> createState() => _OrganizerHomeViewState();
}

class _OrganizerHomeViewState extends State<OrganizerHomeView> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    OrganizerDashboardView(),
    OrganizerEventsView(),
    OrganizerMerchandiseView(),
    OrganizerNotificationsView(),
    OrganizerProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Merchandise',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
