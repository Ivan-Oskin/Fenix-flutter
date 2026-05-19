import 'package:sqflite/sqflite.dart';
import 'package:fenix/model/event.dart';
import 'package:fenix/repository/database_Init.dart';

class EventRepository {
  final DataBaseInit _dbHelper = DataBaseInit.instance;

  // ==================== CRUD ====================

  /// Сохранить событие (вставка или обновление)
  Future<int> saveEvent(Event event) async {
    final db = await _dbHelper.database;

    return await db.insert(
      'event',
      event.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Получить ВСЕ события
  Future<List<Event>> getAllEvents() async {
    final db = await _dbHelper.database;
    final result = await db.query('event');

    return result.map((map) => Event.fromMap(map)).toList();
  }

  /// Получить событие по ID (полная информация)
  Future<Event?> getEventById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'event',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return Event.fromMap(result.first);
    }
    return null;
  }

  /// Получить только title, location, start_date по ID
  Future<Map<String, dynamic>?> getEventBasicInfo(int id) async {
    final db = await _dbHelper.database;

    final result = await db.query(
      'event',
      columns: ['title', 'location', 'start_date'],
      where: 'id = ?',
      whereArgs: [id],
    );

    return result.isNotEmpty ? result.first : null;
  }

  /// Удалить событие
  Future<int> deleteEvent(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('event', where: 'id = ?', whereArgs: [id]);
  }
}