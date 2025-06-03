import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'features/activities/providers/activity_provider.dart';
import 'features/home/screens/home_screen.dart';
import 'features/finances/screens/finance_screen.dart';
import 'features/finances/screens/transaction_details_screen.dart';
import 'shared/services/logger_service.dart';
import 'features/activities/models/activity.dart';
import 'features/budgets/providers/trip_provider.dart';
import 'features/budgets/providers/expense_provider.dart';
import 'features/budgets/pages/budgets_list_page.dart';
import 'features/budgets/pages/trip_details_page.dart';
import 'features/budgets/providers/itinerary_provider.dart';
import 'features/budgets/providers/document_provider.dart';
import 'widgets/green_pills_wallpaper.dart';
import 'core/initialization/app_initializer.dart';
import 'features/finances/models/financial_transaction.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LoggerService.initialize();

  runApp(await AppInitializer.initialize());
}

class AppGradientBackground extends StatelessWidget {
  final Widget child;
  const AppGradientBackground({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF4F8CFF), // Blue
            Color(0xFFB721FF), // Purple
            Color(0xFFFF3A44), // Red
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Activity',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: GreenPillsWallpaper(
        child: HomeScreen(),
      ),
      routes: {
        '/budgets': (context) => GreenPillsWallpaper(
          child: BudgetsListPage(),
        ),
        '/finances': (context) => GreenPillsWallpaper(
          child: const FinanceScreen(),
        ),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/transaction-details') {
          final transaction = settings.arguments as FinancialTransaction;
          return MaterialPageRoute(
            builder: (context) => TransactionDetailsScreen(
              transaction: transaction,
            ),
          );
        }
        if (settings.name == '/trip-details') {
          final tripId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => GreenPillsWallpaper(
              child: TripDetailsPage(tripId: tripId),
            ),
          );
        }
        return null;
      },
    );
  }
}
