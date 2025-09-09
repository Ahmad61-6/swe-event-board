class AppConstants {
  static const String appName = 'Event Board';
  static const String primaryColor = '#1976D2';
  static const String accentColor = '#EF6C00';

  // Storage keys
  static const String themeModeKey = 'theme_mode';
  static const String userProfileKey = 'user_profile';
  static const String userRoleKey = 'user_role';

  // Role types
  static const String roleStudent = 'student';
  static const String roleOrganizer = 'organizer';
  static const String roleAdmin = 'admin';

  // Organization types
  static const String orgTypeClub = 'clubs';
  static const String orgTypeDepartment = 'departments';
  static const String orgTypeThirdParty = 'thirdparty';

  // Event types
  static const List<String> eventTypes = [
    'Tech Talk',
    'Workshop',
    'Conference',
    'Seminar',
    'Competition',
    'Cultural',
    'Sports',
    'Career',
  ];

  // Batch years
  static const List<String> batchYears = [
    '2021',
    '2022',
    '2023',
    '2024',
    '2025',
  ];

  // Admin code (in production, this should be secured)
  static const String adminCode = 'ADMIN2024';
}
