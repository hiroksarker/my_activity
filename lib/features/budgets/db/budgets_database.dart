import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BudgetsDatabase {
  static final BudgetsDatabase instance = BudgetsDatabase._init();
  static Database? _database;

  BudgetsDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('budgets.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    // Trip table
    await db.execute('''
      CREATE TABLE trips (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        destinations TEXT,
        totalBudget REAL NOT NULL,
        baseCurrency TEXT NOT NULL,
        notes TEXT,
        members TEXT,
        budget REAL,
        travelers TEXT
      )
    ''');
    // Expense table
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tripId INTEGER NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        currency TEXT NOT NULL,
        notes TEXT,
        photoPath TEXT,
        paidBy TEXT NOT NULL,
        sharedWith TEXT,
        isSettled INTEGER NOT NULL,
        FOREIGN KEY (tripId) REFERENCES trips(id) ON DELETE CASCADE
      )
    ''');
    // PackingItem table
    await db.execute('''
      CREATE TABLE packing_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tripId INTEGER NOT NULL,
        name TEXT NOT NULL,
        isPacked INTEGER NOT NULL,
        FOREIGN KEY (tripId) REFERENCES trips(id) ON DELETE CASCADE
      )
    ''');
    // ItineraryItem table
    await db.execute('''
      CREATE TABLE itinerary_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tripId INTEGER NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        activity TEXT NOT NULL,
        notes TEXT,
        attachmentPath TEXT,
        FOREIGN KEY (tripId) REFERENCES trips(id) ON DELETE CASCADE
      )
    ''');
    // JournalEntry table
    await db.execute('''
      CREATE TABLE journal_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tripId INTEGER NOT NULL,
        date TEXT NOT NULL,
        note TEXT NOT NULL,
        photoPath TEXT,
        FOREIGN KEY (tripId) REFERENCES trips(id) ON DELETE CASCADE
      )
    ''');
    // Document table
    await db.execute('''
      CREATE TABLE documents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tripId INTEGER NOT NULL,
        type TEXT NOT NULL,
        filePath TEXT NOT NULL,
        description TEXT,
        FOREIGN KEY (tripId) REFERENCES trips(id) ON DELETE CASCADE
      )
    ''');
    // TripInfo table
    await db.execute('''
      CREATE TABLE trip_info (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tripId INTEGER NOT NULL,
        type TEXT NOT NULL,
        value TEXT NOT NULL,
        FOREIGN KEY (tripId) REFERENCES trips(id) ON DELETE CASCADE
      )
    ''');
    // GalleryPhoto table
    await db.execute('''
      CREATE TABLE gallery_photos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tripId INTEGER NOT NULL,
        filePath TEXT NOT NULL,
        source TEXT NOT NULL,
        FOREIGN KEY (tripId) REFERENCES trips(id) ON DELETE CASCADE
      )
    ''');
    // ExchangeRate table
    await db.execute('''
      CREATE TABLE exchange_rates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fromCurrency TEXT NOT NULL,
        toCurrency TEXT NOT NULL,
        rate REAL NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE trips ADD COLUMN budget REAL;');
      await db.execute('ALTER TABLE trips ADD COLUMN travelers TEXT;');
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
