import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDbService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'my_activity.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ledger_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            description TEXT,
            debit REAL,
            credit REAL,
            account TEXT,
            category TEXT,
            notes TEXT
          )
        ''');
        // Add other tables as needed
      },
      version: 1,
    );
  }

  // CRUD methods for ledger_entries
  static Future<int> insertLedgerEntry(Map<String, dynamic> entry) async {
    final db = await database;
    return db.insert('ledger_entries', entry);
  }

  static Future<List<Map<String, dynamic>>> getLedgerEntries() async {
    final db = await database;
    return db.query('ledger_entries', orderBy: 'date DESC');
  }

  static Future<int> updateLedgerEntry(Map<String, dynamic> entry) async {
    final db = await database;
    return db.update(
      'ledger_entries',
      entry,
      where: 'id = ?',
      whereArgs: [entry['id']],
    );
  }

  static Future<int> deleteLedgerEntry(int id) async {
    final db = await database;
    return db.delete('ledger_entries', where: 'id = ?', whereArgs: [id]);
  }
}
