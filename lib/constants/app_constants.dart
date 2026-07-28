/// Application-wide constants
class AppConstants {
  // App info
  static const String appName = 'Campus Meal Tracker';
  static const String appVersion = '1.0.0';

  // Default values
  static const double defaultLunchPrice = 80.0;
  static const double defaultDinnerPrice = 80.0;
  static const double defaultDeposit = 5000.0;
  static const double defaultLowBalanceThreshold = 500.0;

  // Hive box names
  static const String mealsBox = 'meals';
  static const String contractBox = 'contract';
  static const String settingsBox = 'settings';

  // Storage keys
  static const String currentContractKey = 'current_contract';
  static const String settingsKey = 'app_settings';

  // Animation durations
  static const int animationDurationMs = 300;
  static const int shortAnimationDurationMs = 150;

  // Card border radius
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;

  // Spacing
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // Font sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 20.0;
  static const double fontSizeXXLarge = 24.0;

  // Validation
  static const double minDeposit = 100.0;
  static const double maxDeposit = 100000.0;
  static const double minMealPrice = 1.0;
  static const double maxMealPrice = 1000.0;
  static const int maxStudentNameLength = 50;

  // Export
  static const String csvExtension = '.csv';
  static const String pdfExtension = '.pdf';
  static const String backupExtension = '.json';
}
