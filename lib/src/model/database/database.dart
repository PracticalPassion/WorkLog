import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timing/src/model/database/timeEntry.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> initDatabase() async {
    await deleteThisDatabase();

    print('initDatabase');
    _database = await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'time_tracking.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE time_tracking_entries (
        id INTEGER PRIMARY KEY,
        expected_work_hours REAL,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE time_entries (
        id INTEGER PRIMARY KEY,
        start TEXT,
        end TEXT,
        tracking_entry_id INTEGER,
        FOREIGN KEY(tracking_entry_id) REFERENCES time_tracking_entries(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> deleteThisDatabase() async {
    String path = join(await getDatabasesPath(), 'time_tracking.db');
    await deleteDatabase(path);
  }
}
