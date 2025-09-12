import 'package:flutter/material.dart';

import 'dashboard/student_dashboard_view.dart';
import 'enrollments/student_enrollments_view.dart';
import 'notifications/student_notifications_view.dart';
import 'profile/student_profile_view.dart';
import 'search/student_search_view.dart';

class StudentHomeView extends StatefulWidget {
  const StudentHomeView({super.key});

  @override
  State<StudentHomeView> createState() => _StudentHomeViewState();
}

class _StudentHomeViewState extends State<StudentHomeView> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    StudentDashboardView(),
    StudentEnrollmentsView(),
    StudentSearchView(),
    StudentNotificationsView(),
    StudentProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get current theme

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme
              .cardColor, // Use theme's card color instead of hardcoded white
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(
                alpha: 0.1,
              ), // Use theme's shadow color
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors
              .transparent, // Keep transparent to show container background
          elevation: 0,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: theme.primaryColor, // Use theme's primary color
          unselectedItemColor:
              theme.unselectedWidgetColor, // Use theme's unselected color
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 24),
              activeIcon: Icon(Icons.home, size: 24),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_outlined, size: 24),
              activeIcon: Icon(Icons.event, size: 24),
              label: 'Enrollments',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined, size: 24),
              activeIcon: Icon(Icons.search, size: 24),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined, size: 24),
              activeIcon: Icon(Icons.notifications, size: 24),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 24),
              activeIcon: Icon(Icons.person, size: 24),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
