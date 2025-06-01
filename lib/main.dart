import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'features/home/providers/activity_provider.dart';
import 'features/home/screens/home_screen.dart';
import 'features/finances/screens/finance_screen.dart';
import 'features/finances/screens/transaction_details_screen.dart';
import 'shared/utils/logger.dart';
import 'features/home/models/activity.dart';
import 'features/budgets/providers/trip_provider.dart';
import 'features/budgets/providers/expense_provider.dart';
import 'features/budgets/pages/budgets_list_page.dart';
import 'features/budgets/pages/trip_details_page.dart';
import 'features/budgets/providers/itinerary_provider.dart';
import 'features/budgets/providers/document_provider.dart';
import 'widgets/green_pills_wallpaper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize logger
  LoggerService.initialize();
  final logger = LoggerService.logger;
  
  try {
    logger.i('Initializing local database...');
    
    // Open the database
    final database = await openDatabase(
      join(await getDatabasesPath(), 'my_activity.db'),
      version: 2,
      onCreate: (db, version) async {
        // Create tables
        await db.execute('''
          CREATE TABLE IF NOT EXISTS activities (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            amount REAL,
            category TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            type TEXT NOT NULL,
            status TEXT NOT NULL,
            transactionType TEXT NOT NULL,
            isRecurring INTEGER NOT NULL DEFAULT 0,
            recurrenceType TEXT,
            nextOccurrence TEXT,
            recurrenceRule TEXT,
            metadata TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS activity_history (
            id TEXT PRIMARY KEY,
            activityId TEXT NOT NULL,
            changeType TEXT NOT NULL,
            changeDescription TEXT,
            timestamp TEXT NOT NULL,
            FOREIGN KEY (activityId) REFERENCES activities (id) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS budgets (
            id TEXT PRIMARY KEY,
            category TEXT NOT NULL,
            amount REAL NOT NULL,
            period TEXT NOT NULL,
            startDate TEXT NOT NULL,
            endDate TEXT,
            description TEXT,
            isActive INTEGER NOT NULL,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            metadata TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add the metadata column if it doesn't exist
          await db.execute('ALTER TABLE budgets ADD COLUMN metadata TEXT;');
        }
      },
    );

    // Initialize providers
    final activityProvider = ActivityProvider(database);
    final tripProvider = TripProvider();
    final expenseProvider = ExpenseProvider();

    logger.i('Local database initialized successfully');

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ActivityProvider>(
            create: (_) => activityProvider,
          ),
          ChangeNotifierProvider<TripProvider>(
            create: (_) => tripProvider,
          ),
          ChangeNotifierProvider<ExpenseProvider>(
            create: (_) => expenseProvider,
          ),
          ChangeNotifierProvider<ItineraryProvider>(
            create: (_) => ItineraryProvider(),
          ),
          ChangeNotifierProvider<DocumentProvider>(
            create: (_) => DocumentProvider(),
          ),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    logger.e('Failed to initialize database', error: e, stackTrace: stackTrace);
    rethrow;
  }
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
        '/budgets': (context) => BudgetsListPage(),
        '/finances': (context) => const FinanceScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/transaction-details') {
          final transaction = settings.arguments as Activity;
          return MaterialPageRoute(
            builder: (context) => TransactionDetailsScreen(transaction: transaction),
          );
        }
        if (settings.name == '/trip-details') {
          final tripId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => TripDetailsPage(tripId: tripId),
          );
        }
        return null;
      },
    );
  }
}
