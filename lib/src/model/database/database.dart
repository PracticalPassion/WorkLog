import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'time_tracking.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> initDatabase() async {
    await deleteThisDatabase();
    _database = await _initDatabase();
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE time_entries (
        id INTEGER PRIMARY KEY,
        start TEXT,
        end TEXT
      )
    ''');
  }

  Future<void> deleteThisDatabase() async {
    String path = join(await getDatabasesPath(), 'time_tracking.db');
    await deleteDatabase(path);
  }
}
