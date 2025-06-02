import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../main.dart';
import '../services/logger_service.dart';
import '../../features/activities/providers/activity_provider.dart';
import '../../features/activities/models/activity.dart';

class AppInitializer {
  static Future<Widget> initialize() async {
    final logger = LoggerService.logger;
    
    try {
      logger.info('Initializing local database...');
      
      // Initialize database factory for web platform
      if (kIsWeb) {
        // For web, we'll use IndexedDB through sqflite_common_ffi_web
        databaseFactory = databaseFactoryFfiWeb;
        // Initialize the web worker
        await databaseFactoryFfiWeb.setDatabasesPath('my_activity_db');
      }
      
      final database = await openDatabase(
        join(await getDatabasesPath(), 'my_activity.db'),
        version: 5,
        onCreate: (db, version) async {
          logger.info('Creating database tables...');
          await _createTables(db);
          logger.info('Database tables created successfully');
        },
        onUpgrade: _handleDatabaseUpgrade,
        onOpen: (db) async {
          logger.info('Database opened successfully');
          // Verify tables exist
          await _createTables(db);
        },
      );

      final path = await getDatabasesPath();
      logger.info('Database path: $path');

      logger.info('Local database and providers initialized successfully');

      return MultiProvider(
        providers: [
          ChangeNotifierProvider<ActivityProvider>(
            create: (_) => ActivityProvider(database),
          ),
        ],
        child: const MyApp(),
      );
    } catch (e, stackTrace) {
      logger.severe('Failed to initialize app', e, stackTrace);
      rethrow;
    }
  }

  static Future<void> _createTables(Database db) async {
    // Create activities table
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
        transactionType TEXT,
        isRecurring INTEGER NOT NULL DEFAULT 0,
        recurrenceType TEXT,
        nextOccurrence TEXT,
        recurrenceRule TEXT,
        metadata TEXT
      )
    ''');

    // Create activity history table
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

    // Create budgets table
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
  }

  static Future<void> _handleDatabaseUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 5) {
      // Make transactionType nullable
      try {
        // Create a temporary table with the new schema
        await db.execute('''
          CREATE TABLE activities_temp (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            amount REAL,
            category TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            type TEXT NOT NULL,
            status TEXT NOT NULL,
            transactionType TEXT,
            isRecurring INTEGER NOT NULL DEFAULT 0,
            recurrenceType TEXT,
            nextOccurrence TEXT,
            recurrenceRule TEXT,
            metadata TEXT
          )
        ''');

        // Copy data from the old table to the new one
        await db.execute('''
          INSERT INTO activities_temp
          SELECT 
            id, title, description, amount, category, 
            createdAt, updatedAt, type, status, 
            CASE 
              WHEN type = 'task' THEN NULL 
              ELSE transactionType 
            END as transactionType,
            isRecurring, recurrenceType, nextOccurrence, 
            recurrenceRule, metadata
          FROM activities
        ''');

        // Drop the old table
        await db.execute('DROP TABLE activities');

        // Rename the new table to the original name
        await db.execute('ALTER TABLE activities_temp RENAME TO activities');

        // Recreate indexes and foreign keys if any
        await db.execute('''
          CREATE INDEX IF NOT EXISTS idx_activities_type 
          ON activities(type)
        ''');
      } catch (e) {
        print('Error upgrading database: $e');
        rethrow;
      }
    }
  }

  static Future<List<ChangeNotifierProvider>> _initializeProviders(Database database) async {
    return [
      ChangeNotifierProvider<ActivityProvider>(
        create: (_) => ActivityProvider(database),
      ),
    ];
  }
} 