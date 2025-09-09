import 'package:flutter/material.dart';

import 'dashboard/student_dashboard_view.dart';
import 'enrollments/student_enrollments_view.dart';
import 'notifications/student_notifications_view.dart';
import 'profile/student_profile_view.dart';
import 'search/student_search_view.dart';

class StudentHomeView extends StatefulWidget {
  const StudentHomeView({Key? key}) : super(key: key);

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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'My Events'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
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
