import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/onboarding_controller.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = Get.put(OnboardingController());
    final PageController pageController = PageController();

    final List<Map<String, dynamic>> onboardingPages = [
      {
        'icon': Icons.event,
        'title': 'Discover Exciting Events',
        'description':
            'Find events hosted by various university organizations and clubs, all in one place.',
        'color': Colors.blue,
      },
      {
        'icon': Icons.calendar_today,
        'title': 'Stay Organized & Informed',
        'description':
            'Keep track of your event schedule, get reminders, and never miss out on what\'s happening on campus.',
        'color': Colors.green,
      },
      {
        'icon': Icons.groups,
        'title': 'Engage with Your Community',
        'description':
            'Connect with fellow students, join organizations, and become an active part of the university community.',
        'color': Colors.orange,
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: controller.completeOnboarding,
                child: const Text(
                  'Skip',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: onboardingPages.length,
                itemBuilder: (context, index) {
                  final page = onboardingPages[index];
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Enhanced Icon Container
                        Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            color: page['color'].withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page['icon'],
                            size: 120,
                            color: page['color'],
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          page['title']!,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: page['color'],
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page['description']!,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Colors.grey[700], height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page Indicators
                  Obx(
                    () => Row(
                      children: List.generate(
                        onboardingPages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 10,
                          width: controller.currentPage.value == index
                              ? 30
                              : 10,
                          decoration: BoxDecoration(
                            color: controller.currentPage.value == index
                                ? Theme.of(context).primaryColor
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Navigation Button
                  Obx(
                    () => Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.8),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: FloatingActionButton(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        onPressed: () {
                          if (controller.currentPage.value ==
                              onboardingPages.length - 1) {
                            controller.completeOnboarding();
                          } else {
                            pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Icon(
                          controller.currentPage.value ==
                                  onboardingPages.length - 1
                              ? Icons.check
                              : Icons.arrow_forward,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
