abstract class AppRoutes {
  static const splash = '/splash';
  static const initial = '/onboarding'; // Changed initial route
  static const onboarding = '/onboarding';
  static const roleSelection = '/role-selection';
  static const studentSignup = '/student-signup';
  static const organizerSignup = '/organizer-signup';
  static const adminSignup = '/admin-signup';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';

  // Student routes
  static const studentDashboard = '/student/dashboard';
  static const studentEnrollments = '/student/enrollments';
  static const studentSearch = '/student/search';
  static const studentNotifications = '/student/notifications';
  static const studentProfile = '/student/profile';
  static const allEvents = '/student/events/all';
  static const eventDetail = '/event/detail';

  // Organizer routes
  static const organizerDashboard = '/organizer/dashboard';
  static const organizerEvents = '/organizer/events';
  static const organizerCreateEvent = '/organizer/events/create';
  static const organizerMerchandise = '/organizer/merchandise';
  static const organizerProfile = '/organizer/profile';
  static const organizerNotifications = '/organizer/notifications';
  static const organizerEventEnrollments = '/organizer/events/enrollments';

  // Admin routes
  static const adminDashboard = '/admin/dashboard';
  static const adminEvents = '/admin/events';
  static const adminOrganizations = '/admin/organizations';
  static const adminUsers = '/admin/users';
  static const adminNotifications = '/admin/notifications';
  static const adminProfile = '/admin/profile';

  static String getHomeRoute(String role) {
    switch (role) {
      case 'student':
        return studentDashboard;
      case 'organizer':
        return organizerDashboard;
      case 'admin':
        return adminDashboard;
      default:
        return initial;
    }
  }
}
