import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/activity.dart';
import '../models/activity_history.dart';
import 'dart:convert';

class ActivityDatabase {
  static const _databaseName = 'activity_database.db';
  static const _databaseVersion = 1;

  static const _activitiesTable = 'activities';
  static const _historyTable = 'activity_history';

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_activitiesTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        status TEXT NOT NULL,
        transactionType TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $_historyTable (
        id TEXT PRIMARY KEY,
        activityId TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        action TEXT NOT NULL,
        previousState TEXT,
        newState TEXT,
        changeDescription TEXT,
        FOREIGN KEY (activityId) REFERENCES $_activitiesTable (id) ON DELETE CASCADE
      )
    ''');

    // Create index for faster history queries
    await db.execute('''
      CREATE INDEX idx_activity_history_activityId 
      ON $_historyTable (activityId)
    ''');
  }

  // Activity CRUD operations
  Future<List<Activity>> getActivities() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _activitiesTable,
      orderBy: 'timestamp DESC',
    );
    
    try {
      return maps.map((map) {
        // Create a new mutable map from the read-only map
        final mutableMap = Map<String, dynamic>.from(map);
        // Convert timestamp string to DateTime if needed
        if (mutableMap['timestamp'] is String) {
          mutableMap['timestamp'] = DateTime.parse(mutableMap['timestamp']);
        }
        return Activity.fromMap(mutableMap);
      }).toList();
    } catch (e) {
      print('Error loading activities: $e');
      print('Maps data: $maps');
      rethrow;
    }
  }

  Future<void> insertActivity(Activity activity) async {
    final db = await database;
    await db.insert(
      _activitiesTable,
      activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateActivity(Activity activity) async {
    final db = await database;
    await db.update(
      _activitiesTable,
      activity.toMap(),
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }

  Future<void> deleteActivity(String id) async {
    final db = await database;
    await db.delete(
      _activitiesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // History operations
  Future<List<ActivityHistory>> getActivityHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _historyTable,
      orderBy: 'timestamp DESC',
    );
    return maps.map((map) {
      // Convert JSON strings back to maps
      if (map['previousState'] != null) {
        map['previousState'] = json.decode(map['previousState']);
      }
      if (map['newState'] != null) {
        map['newState'] = json.decode(map['newState']);
      }
      return ActivityHistory.fromJson(map);
    }).toList();
  }

  Future<void> insertActivityHistory(ActivityHistory history) async {
    final db = await database;
    final map = history.toJson();
    
    // Convert maps to JSON strings for storage
    if (map['previousState'] != null) {
      map['previousState'] = json.encode(map['previousState']);
    }
    if (map['newState'] != null) {
      map['newState'] = json.encode(map['newState']);
    }

    await db.insert(
      _historyTable,
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ActivityHistory>> getActivityHistoryById(String activityId) async {
    final db = await database;
    try {
      print('Fetching history for activity: $activityId');
      final List<Map<String, dynamic>> maps = await db.query(
        _historyTable,
        where: 'activityId = ?',
        whereArgs: [activityId],
        orderBy: 'timestamp DESC',
      );
      
      print('Found ${maps.length} history entries');
      return maps.map((map) {
        try {
          // Create a mutable copy of the map
          final mutableMap = Map<String, dynamic>.from(map);
          
          // Convert timestamp string to DateTime if needed
          if (mutableMap['timestamp'] is String) {
            mutableMap['timestamp'] = DateTime.parse(mutableMap['timestamp']);
          }
          
          // Decode JSON strings for state maps
          if (mutableMap['previousState'] != null) {
            try {
              mutableMap['previousState'] = json.decode(mutableMap['previousState'] as String);
            } catch (e) {
              print('Error decoding previousState: $e');
              mutableMap['previousState'] = null;
            }
          }
          
          if (mutableMap['newState'] != null) {
            try {
              mutableMap['newState'] = json.decode(mutableMap['newState'] as String);
            } catch (e) {
              print('Error decoding newState: $e');
              mutableMap['newState'] = null;
            }
          }
          
          return ActivityHistory.fromJson(mutableMap);
        } catch (e) {
          print('Error processing history entry: $e');
          print('Map data: $map');
          rethrow;
        }
      }).toList();
    } catch (e) {
      print('Error fetching activity history: $e');
      rethrow;
    }
  }
} 