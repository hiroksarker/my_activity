import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../main.dart';
import '../../shared/services/logger_service.dart';
import '../../features/activities/providers/activity_provider.dart';
import '../../features/activities/models/activity.dart';
import '../../features/profile/providers/user_provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/budgets/providers/trip_provider.dart';
import '../../features/finances/providers/transaction_provider.dart';
import '../../features/itinerary/providers/itinerary_provider.dart';
import '../../features/documents/providers/document_provider.dart';
import '../../features/expenses/providers/expense_provider.dart';

class AppInitializer {
  static Future<Widget> initialize() async {
    final logger = LoggerService.logger;
    
    try {
      logger.i('Initializing local database...');
      
      final database = await openDatabase(
        join(await getDatabasesPath(), 'my_activity.db'),
        version: 9, // Increment version to trigger fresh database creation
        onCreate: (db, version) async {
          logger.i('Creating database tables...');
          await _createTables(db);
          logger.i('Database tables created successfully');
        },
        onUpgrade: _handleDatabaseUpgrade,
      );

      final path = await getDatabasesPath();
      logger.i('Database path: $path');

      logger.i('Local database and providers initialized successfully');

      return MultiProvider(
        providers: [
          ChangeNotifierProvider<ActivityProvider>(
            create: (_) => ActivityProvider(database),
          ),
          ChangeNotifierProvider<TransactionProvider>(
            create: (_) => TransactionProvider(database),
          ),
          ChangeNotifierProvider<TripProvider>(
            create: (_) => TripProvider(),
          ),
          ChangeNotifierProvider<ItineraryProvider>(
            create: (_) => ItineraryProvider(),
          ),
          ChangeNotifierProvider<DocumentProvider>(
            create: (_) => DocumentProvider(),
          ),
          ChangeNotifierProvider<ExpenseProvider>(
            create: (_) => ExpenseProvider(),
          ),
        ],
        child: const MyApp(),
      );
    } catch (e, stackTrace) {
      logger.e('Failed to initialize app', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  static Future<void> _createTables(Database db) async {
    // Create activities table (without financial fields)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS activities (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        priority TEXT NOT NULL DEFAULT 'regular',
        recurrenceType TEXT,
        nextOccurrence TEXT
      )
    ''');

    // Create transactions table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS transactions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        subcategory TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        type TEXT NOT NULL,
        isRecurring INTEGER NOT NULL DEFAULT 0,
        recurrenceType TEXT,
        nextOccurrence TEXT,
        recurrenceRule TEXT,
        metadata TEXT,
        categoryIcon TEXT,
        categoryColor TEXT
      )
    ''');

    // Create categories table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        name TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        isCustom INTEGER NOT NULL DEFAULT 0,
        icon TEXT,
        color TEXT
      )
    ''');

    // Insert default categories for both activities and transactions
    await db.execute('''
      INSERT OR IGNORE INTO categories (name, type, isCustom) VALUES
      ('Personal', 'activity', 0),
      ('Work', 'activity', 0),
      ('Others', 'activity', 0),
      ('Food & Dining', 'transaction', 0),
      ('Transportation', 'transaction', 0),
      ('Shopping', 'transaction', 0),
      ('Entertainment', 'transaction', 0),
      ('Bills & Utilities', 'transaction', 0),
      ('Health & Medical', 'transaction', 0),
      ('Travel', 'transaction', 0),
      ('Education', 'transaction', 0),
      ('Salary', 'transaction', 0),
      ('Investments', 'transaction', 0),
      ('Gifts', 'transaction', 0),
      ('Other Income', 'transaction', 0)
    ''');

    // Create activity history table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS activity_history (
        id TEXT PRIMARY KEY,
        activityId TEXT NOT NULL,
        action TEXT NOT NULL,
        description TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        changes TEXT,
        FOREIGN KEY (activityId) REFERENCES activities (id) ON DELETE CASCADE
      )
    ''');

    // Create transaction history table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS transaction_history (
        id TEXT PRIMARY KEY,
        transactionId TEXT NOT NULL,
        action TEXT NOT NULL,
        description TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        changes TEXT,
        FOREIGN KEY (transactionId) REFERENCES transactions (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for activities
    await db.execute('CREATE INDEX IF NOT EXISTS idx_activities_type ON activities(type)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_activities_status ON activities(status)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_activities_category ON activities(category)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_activities_createdAt ON activities(createdAt)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_activities_priority ON activities(priority)');

    // Create indexes for transactions
    await db.execute('CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions(type)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_transactions_category ON transactions(category)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_transactions_createdAt ON transactions(createdAt)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_transactions_amount ON transactions(amount)');

    // Create indexes for history tables
    await db.execute('CREATE INDEX IF NOT EXISTS idx_activity_history_activityId ON activity_history(activityId)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_activity_history_timestamp ON activity_history(timestamp)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_transaction_history_transactionId ON transaction_history(transactionId)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_transaction_history_timestamp ON transaction_history(timestamp)');
  }

  static Future<void> _handleDatabaseUpgrade(Database db, int oldVersion, int newVersion) async {
    // For a fresh start, we'll drop and recreate all tables
    if (oldVersion < 9) { // Increment version number
      // Drop existing tables
      await db.execute('DROP TABLE IF EXISTS activities');
      await db.execute('DROP TABLE IF EXISTS transactions');
      await db.execute('DROP TABLE IF EXISTS categories');
      await db.execute('DROP TABLE IF EXISTS activity_history');
      await db.execute('DROP TABLE IF EXISTS transaction_history');

      // Recreate tables with new schema
      await _createTables(db);
    }
  }

  static Future<List<ChangeNotifierProvider>> _initializeProviders(Database database) async {
    return [
      ChangeNotifierProvider<ActivityProvider>(
        create: (_) => ActivityProvider(database),
      ),
    ];
  }

  static Future<void> deleteOldDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'my_activity.db');
    await deleteDatabase(path);
    print('Deleted database at $path');
  }

  static Future<void> ensureActivitiesTableColumns(Database db) async {
    final columns = await db.rawQuery("PRAGMA table_info(activities)");
    final columnNames = columns.map((col) => col['name'] as String).toSet();

    // Drop unused columns if they exist
    final columnsToDrop = [
      'subcategory',
      'taskStatus',
      'taskType',
      'dueDate',
      'metadata',
      'recurrenceRule',
      'isRecurring',
      'transactionType'
    ];

    for (final col in columnsToDrop) {
      if (columnNames.contains(col)) {
        // SQLite doesn't support DROP COLUMN directly, so we need to recreate the table
        await _recreateActivitiesTable(db);
        break;
      }
    }
  }

  static Future<void> _recreateActivitiesTable(Database db) async {
    // Create temporary table with new schema
    await db.execute('''
      CREATE TABLE activities_temp (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        priority TEXT NOT NULL DEFAULT 'regular',
        recurrenceType TEXT,
        nextOccurrence TEXT
      )
    ''');

    // Copy only valid data from old table to new table
    // Filter out any rows with NULL values in required fields
    await db.execute('''
      INSERT INTO activities_temp (
        id, title, description, category, 
        createdAt, updatedAt, type, status, priority,
        recurrenceType, nextOccurrence
      )
      SELECT 
        id,
        COALESCE(title, 'Untitled Activity'),
        COALESCE(description, ''),
        COALESCE(category, 'Others'),
        COALESCE(createdAt, datetime('now')),
        COALESCE(updatedAt, datetime('now')),
        COALESCE(type, 'expense'),
        COALESCE(status, 'pending'),
        COALESCE(priority, 'regular'),
        CASE 
          WHEN isRecurring = 1 AND recurrenceType IN ('daily', 'weekly', 'monthly', 'yearly') 
          THEN recurrenceType 
          ELSE NULL 
        END,
        CASE 
          WHEN isRecurring = 1 AND recurrenceType IN ('daily', 'weekly', 'monthly', 'yearly')
          THEN nextOccurrence
          ELSE NULL
        END
      FROM activities
      WHERE id IS NOT NULL
        AND title IS NOT NULL
        AND category IS NOT NULL
        AND type IS NOT NULL
        AND status IS NOT NULL
    ''');

    // Drop old table and rename new table
    await db.execute('DROP TABLE activities');
    await db.execute('ALTER TABLE activities_temp RENAME TO activities');

    // Recreate indexes
    await db.execute('CREATE INDEX IF NOT EXISTS idx_activities_type ON activities(type)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_activities_status ON activities(status)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_activities_category ON activities(category)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_activities_createdAt ON activities(createdAt)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_activities_priority ON activities(priority)');
  }
} 