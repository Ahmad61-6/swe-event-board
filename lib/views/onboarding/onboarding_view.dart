import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/onboarding_controller.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final OnboardingController controller = Get.put(OnboardingController());
    final PageController pageController = PageController();

    final List<Map<String, String>> onboardingPages = [
      {
        'image': 'assets/images/onboarding_1.png', // Replace with your asset
        'title': 'Discover Exciting Events',
        'description': 'Find events hosted by various university organizations and clubs, all in one place.',
      },
      {
        'image': 'assets/images/onboarding_2.png', // Replace with your asset
        'title': 'Stay Organized & Informed',
        'description': 'Keep track of your event schedule, get reminders, and never miss out on what\'s happening on campus.',
      },
      {
        'image': 'assets/images/onboarding_3.png', // Replace with your asset
        'title': 'Engage with Your Community',
        'description': 'Connect with fellow students, join organizations, and become an active part of the university community.',
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
                child: const Text('Skip'),
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
                        // TODO: Replace with actual image assets
                        Icon(Icons.event_seat, size: 150, color: Theme.of(context).primaryColor),
                        const SizedBox(height: 48),
                        Text(
                          page['title']!,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page['description']!,
                          style: Theme.of(context).textTheme.bodyLarge,
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
                  Obx(() => Row(
                        children: List.generate(
                          onboardingPages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: controller.currentPage.value == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: controller.currentPage.value == index
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      )),
                  Obx(() => FloatingActionButton(
                        onPressed: () {
                          if (controller.currentPage.value == onboardingPages.length - 1) {
                            controller.completeOnboarding();
                          } else {
                            pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Icon(
                          controller.currentPage.value == onboardingPages.length - 1
                              ? Icons.check
                              : Icons.arrow_forward,
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
