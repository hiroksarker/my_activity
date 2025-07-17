class AppConstants {
  // App Information
  static const String appName = 'My Activity';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'my_activity.db';
  static const int databaseVersion = 9;
  
  // Shared Preferences Keys
  static const String keyUserData = 'user_data';
  static const String keyProfileImagePath = 'profile_image_path';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  
  // API Endpoints (if needed in future)
  static const String baseUrl = 'https://api.myactivity.com/v1';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const double cardElevation = 2.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;
  
  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';
  static const String displayDateFormat = 'MMM d, y';
  
  // Categories
  static const List<String> defaultActivityCategories = [
    'Personal',
    'Work',
    'Health',
    'Education',
    'Entertainment',
    'Others',
  ];
  
  static const List<String> defaultTransactionCategories = [
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Bills & Utilities',
    'Health & Medical',
    'Travel',
    'Education',
    'Salary',
    'Investments',
    'Gifts',
    'Other Income',
  ];
}