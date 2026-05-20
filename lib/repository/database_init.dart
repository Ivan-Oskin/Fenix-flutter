import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataBaseInit {
  static final DataBaseInit instance = DataBaseInit._init();
  static Database? _database;

  DataBaseInit._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    // Таблица Profile
    await db.execute('''
    CREATE TABLE IF NOT EXISTS profile (
      id INTEGER PRIMARY KEY,
      username TEXT,
      token TEXT,
      name TEXT,
      surname TEXT,
      patronymic TEXT
    );
  ''');

    // Таблица Event
    await db.execute('''
    CREATE TABLE IF NOT EXISTS event (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT,
      location TEXT,
      start_date TEXT,
      speaker_id INTEGER,
      photo_path TEXT,
      presentation_path TEXT
    );
  ''');

    // Таблица Polls
    await db.execute('''
    CREATE TABLE IF NOT EXISTS polls (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      meeting_id TEXT,
      title TEXT,
      url TEXT
    );
  ''');
  }
}
