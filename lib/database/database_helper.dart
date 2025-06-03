import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'my_activity.db');

    return await openDatabase(
      path,
      version: 2, // Increment version to trigger migration
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Drop the old table and create a new one with the correct schema
      await db.execute('DROP TABLE IF EXISTS activity_history');
      await db.execute('''
        CREATE TABLE activity_history (
          id TEXT PRIMARY KEY,
          activityId TEXT NOT NULL,
          action TEXT NOT NULL,
          description TEXT NOT NULL,
          timestamp TEXT NOT NULL,
          changes TEXT,
          FOREIGN KEY (activityId) REFERENCES activities (id) ON DELETE CASCADE
        )
      ''');
    }
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE activities (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        amount REAL,
        category TEXT NOT NULL,
        subcategory TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        type TEXT NOT NULL,
        status TEXT NOT NULL,
        transactionType TEXT,
        isRecurring INTEGER NOT NULL DEFAULT 0,
        recurrenceType TEXT,
        nextOccurrence TEXT,
        recurrenceRule TEXT,
        metadata TEXT,
        priority TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE activity_history (
        id TEXT PRIMARY KEY,
        activityId TEXT NOT NULL,
        action TEXT NOT NULL,
        description TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        changes TEXT,
        FOREIGN KEY (activityId) REFERENCES activities (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
} 