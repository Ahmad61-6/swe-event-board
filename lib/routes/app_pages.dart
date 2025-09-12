import 'package:event_board/views/admin/events/admin_events_view.dart';
import 'package:event_board/views/admin/organizations/admin_organizations_view.dart';
import 'package:event_board/views/admin/users/admin_users_view.dart';
import 'package:event_board/views/organizer/events/organizer_events_view.dart';
import 'package:event_board/views/splash/splash_view.dart';
import 'package:event_board/views/student/events/all_events_view.dart';
import 'package:get/get.dart';

import '../bindings/auth_binding.dart';
import '../routes/guards/admin_guard.dart';
import '../routes/guards/organizer_guard.dart';
import '../routes/guards/student_guard.dart';
import '../views/admin/admin_home_view.dart';
import '../views/admin/notifications/admin_notifications_view.dart';
import '../views/admin/profile/admin_profile_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/role_selection_view.dart';
import '../views/auth/signup/admin_signup_view.dart';
import '../views/auth/signup/organizer_signup_view.dart';
import '../views/auth/signup/student_signup_view.dart';
import '../views/onboarding/onboarding_view.dart';
import '../views/organizer/events/create_event_view.dart';
import '../views/organizer/notifications/organizer_notifications_view.dart';
import '../views/organizer/organizer_home_view.dart';
import '../views/organizer/profile/organizer_profile_view.dart';
import '../views/shared/unauthorized_view.dart';
import '../views/student/events/event_detail_view.dart';
import '../views/student/profile/student_profile_view.dart';
import '../views/student/student_home_view.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => SplashView(),
      binding: AuthBinding(),
    ),
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingView()),
    GetPage(
      name: AppRoutes.initial,
      page: () => const RoleSelectionView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.roleSelection,
      page: () => const RoleSelectionView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.studentSignup,
      page: () => const StudentSignupView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.organizerSignup,
      page: () => const OrganizerSignupView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.adminSignup,
      page: () => const AdminSignupView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.studentDashboard,
      page: () => const StudentHomeView(),
      binding: AuthBinding(),
      middlewares: [StudentGuard()],
    ),
    GetPage(
      name: AppRoutes.studentProfile,
      page: () => const StudentProfileView(),
      binding: AuthBinding(),
      middlewares: [StudentGuard()],
    ),
    GetPage(
      name: AppRoutes.allEvents,
      page: () => AllEventsView(),
      binding: AuthBinding(),
      middlewares: [StudentGuard()],
    ),
    GetPage(
      name: AppRoutes.organizerDashboard,
      page: () => const OrganizerHomeView(),
      binding: AuthBinding(),
      middlewares: [OrganizerGuard()],
    ),
    GetPage(
      name: AppRoutes.organizerNotifications,
      page: () => const OrganizerNotificationsView(),
      binding: AuthBinding(),
      middlewares: [OrganizerGuard()],
    ),
    GetPage(
      name: AppRoutes.organizerProfile,
      page: () => const OrganizerProfileView(),
      binding: AuthBinding(),
      middlewares: [OrganizerGuard()],
    ),
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminHomeView(),
      binding: AuthBinding(),
      middlewares: [AdminGuard()],
    ),
    GetPage(
      name: AppRoutes.adminNotifications,
      page: () => const AdminNotificationsView(),
      binding: AuthBinding(),
      middlewares: [AdminGuard()],
    ),
    GetPage(
      name: AppRoutes.adminProfile,
      page: () => const AdminProfileView(),
      binding: AuthBinding(),
      middlewares: [AdminGuard()],
    ),
    GetPage(
      name: AppRoutes.organizerCreateEvent,
      page: () => const CreateEventView(),
      binding: AuthBinding(),
      middlewares: [OrganizerGuard()],
    ),
    GetPage(
      name: AppRoutes.eventDetail,
      page: () => EventDetailView(event: Get.arguments),
      binding: AuthBinding(),
      middlewares: [StudentGuard()],
    ),
    GetPage(
      name: AppRoutes.adminEvents,
      page: () => AdminEventsView(),
      middlewares: [AdminGuard()],
    ),
    GetPage(
      name: AppRoutes.adminOrganizations,
      page: () => AdminOrganizationsView(),
      middlewares: [AdminGuard()],
    ),
    GetPage(
      name: AppRoutes.adminUsers,
      page: () => AdminUsersView(),
      middlewares: [AdminGuard()],
    ),
    GetPage(
      name: AppRoutes.organizerEvents,
      page: () => OrganizerEventsView(),
      middlewares: [OrganizerGuard()],
    ),
    GetPage(name: '/unauthorized', page: () => const UnauthorizedView()),
  ];
}
