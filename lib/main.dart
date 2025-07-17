import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
import 'widgets/modern_background.dart';
import 'core/initialization/app_initializer.dart';
import 'core/theme/app_theme.dart';
import 'features/finances/models/financial_transaction.dart';
import 'features/finances/providers/transaction_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/profile/providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LoggerService.initialize();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize database using AppInitializer
  final database = await openDatabase(
    join(await getDatabasesPath(), 'my_activity.db'),
    version: 9,
    onCreate: (db, version) async {
      await AppInitializer.createTables(db);
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      await AppInitializer.handleDatabaseUpgrade(db, oldVersion, newVersion);
    },
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ActivityProvider(database)),
        ChangeNotifierProvider(create: (_) => TransactionProvider(database)),
        ChangeNotifierProvider(create: (_) => TripProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => DocumentProvider()),
        ChangeNotifierProvider(create: (_) => ItineraryProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: ModernBackground(
        child: const HomeScreen(),
      ),
      routes: {
        '/budgets': (context) => ModernBackground(
          child: BudgetsListPage(),
        ),
        '/finances': (context) => ModernBackground(
          child: const FinanceScreen(),
        ),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/transaction-details') {
          final transaction = settings.arguments as FinancialTransaction;
          return MaterialPageRoute(
            builder: (context) => ModernBackground(
              child: TransactionDetailsScreen(
                transaction: transaction,
              ),
            ),
          );
        }
        if (settings.name == '/trip-details') {
          final tripId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => ModernBackground(
              child: TripDetailsPage(tripId: tripId),
            ),
          );
        }
        return null;
      },
    );
  }
}
