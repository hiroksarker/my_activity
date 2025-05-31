import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/activity.dart';

class ActivityDatabase {
  static final ActivityDatabase instance = ActivityDatabase._init();
  static Database? _database;

  ActivityDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('activities.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE activities (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        progress REAL NOT NULL,
        notes TEXT
      )
    ''');
  }

  Future<String> create(Activity activity) async {
    final db = await instance.database;
    await db.insert('activities', activity.toMap());
    return activity.id;
  }

  Future<Activity?> read(String id) async {
    final db = await instance.database;
    final maps = await db.query(
      'activities',
      columns: ['id', 'title', 'category', 'date', 'progress', 'notes'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Activity.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Activity>> readAll() async {
    final db = await instance.database;
    final orderBy = 'date DESC';
    final result = await db.query('activities', orderBy: orderBy);

    return result.map((json) => Activity.fromMap(json)).toList();
  }

  Future<List<Activity>> readByCategory(String category) async {
    final db = await instance.database;
    final result = await db.query(
      'activities',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'date DESC',
    );

    return result.map((json) => Activity.fromMap(json)).toList();
  }

  Future<int> update(Activity activity) async {
    final db = await instance.database;
    return db.update(
      'activities',
      activity.toMap(),
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await instance.database;
    return await db.delete(
      'activities',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
} 