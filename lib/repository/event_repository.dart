import 'package:sqflite/sqflite.dart';
import 'package:fenix/model/event.dart';
import 'package:fenix/repository/database_Init.dart';

class EventRepository {
  final DataBaseInit _dbHelper = DataBaseInit.instance;

  // ==================== CRUD ====================

  /// Сохранить событие (вставка или обновление)
  Future<void> saveEvent(Event event) async {
    final db = await _dbHelper.database;

    await db.insert(
      'event',
      {
        'id': event.id,
        'title': event.title,
        'description': event.description,
        'location': event.location,
        'start_date': event.startDate,
        'speaker_id': event.speakerId,
        'photo' : event.photoBytes
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> isEventExists(String eventId) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> result = await db.query(
      'event',
      where: 'id = ?',
      whereArgs: [eventId],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}