import 'package:flutter/material.dart';
import 'features/home/screens/home_screen.dart';
import 'features/auth/pages/login_page.dart';
import 'features/auth/pages/signup_page.dart';
import 'features/finances/screens/finance_screen.dart';
import 'features/budgets/pages/budgets_list_page.dart';
import 'features/profile/pages/profile_page.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/documentation/screens/documentation_screen.dart';
import 'widgets/green_pills_wallpaper.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String finances = '/finances';
  static const String budgets = '/budgets';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String documentation = '/documentation';

  static Map<String, WidgetBuilder> get routes => {
    home: (context) => const HomeScreen(),
    login: (context) => GreenPillsWallpaper(child: const LoginPage()),
    signup: (context) => GreenPillsWallpaper(child: const SignupPage()),
    finances: (context) => GreenPillsWallpaper(child: const FinanceScreen()),
    budgets: (context) => GreenPillsWallpaper(child: BudgetsListPage()),
    profile: (context) => const ProfilePage(),
    settings: (context) => const SettingsScreen(),
    documentation: (context) => const DocumentationScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/transaction-details':
        if (settings.arguments != null) {
          return MaterialPageRoute(
            builder: (context) => GreenPillsWallpaper(
              child: Container(), // Replace with actual transaction details screen
            ),
          );
        }
        break;
      case '/trip-details':
        if (settings.arguments != null) {
          final tripId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => GreenPillsWallpaper(
              child: Container(), // Replace with actual trip details screen
            ),
          );
        }
        break;
    }
    return null;
  }
}