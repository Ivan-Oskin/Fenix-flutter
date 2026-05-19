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

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE profile (
        id INTEGER PRIMARY KEY,
        username TEXT,
        token TEXT,
        name TEXT,
        surname TEXT,
        patronymic TEXT,
      );
      CREATE TABLE event (
        id INTEGER PRIMARY KEY,
        title TEXT,
        description TEXT,
        location TEXT,
        start_date TEXT
        speaker_id INTEGER
      );
    ''');
  }
}