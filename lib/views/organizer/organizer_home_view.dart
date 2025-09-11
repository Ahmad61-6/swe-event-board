import 'package:flutter/material.dart';

import 'dashboard/organizer_dashboard_view.dart';
import 'events/organizer_events_view.dart';
import 'merchandise/organizer_merchandise_view.dart';
import 'notifications/organizer_notifications_view.dart';
import 'profile/organizer_profile_view.dart';

class OrganizerHomeView extends StatefulWidget {
  const OrganizerHomeView({super.key});

  @override
  State<OrganizerHomeView> createState() => _OrganizerHomeViewState();
}

class _OrganizerHomeViewState extends State<OrganizerHomeView> {
  int _currentIndex = 0;
  double _indicatorPosition = 0.0;

  final List<Widget> _pages = [
    const OrganizerDashboardView(),
    OrganizerEventsView(),
    OrganizerMerchandiseView(),
    const OrganizerNotificationsView(),
    const OrganizerProfileView(),
  ];

  final List<Color> _navColors = [
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.redAccent,
  ];

  final List<IconData> _navIcons = [
    Icons.dashboard_rounded,
    Icons.event_rounded,
    Icons.shopping_cart_rounded,
    Icons.notifications_rounded,
    Icons.person_rounded,
  ];

  final List<String> _navLabels = [
    'Dashboard',
    'Events',
    'Merchandise',
    'Notifications',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    _indicatorPosition = _calculateIndicatorPosition(_currentIndex);
  }

  double _calculateIndicatorPosition(int index) {
    return index * (1 / _pages.length) + (1 / (_pages.length * 2));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutQuart,
        height: 80,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Animated background indicator
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutQuart,
              left:
                  _indicatorPosition * screenWidth -
                  (screenWidth / _pages.length / 2),
              bottom: 8,
              child: Container(
                width: screenWidth / _pages.length,
                height: 4,
                decoration: BoxDecoration(
                  color: _navColors[_currentIndex],
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [
                      _navColors[_currentIndex],
                      _navColors[_currentIndex].withValues(alpha: 0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            // Navigation items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_pages.length, (index) {
                final isSelected = index == _currentIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentIndex = index;
                        _indicatorPosition = _calculateIndicatorPosition(index);
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _navColors[index].withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated icon
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _navColors[index].withValues(alpha: 0.2)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _navIcons[index],
                              color: isSelected
                                  ? _navColors[index]
                                  : theme.unselectedWidgetColor,
                              size: isSelected ? 24 : 22,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Animated label
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              fontSize: isSelected ? 12 : 11,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? _navColors[index]
                                  : theme.unselectedWidgetColor,
                            ),
                            child: Text(
                              _navLabels[index],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
