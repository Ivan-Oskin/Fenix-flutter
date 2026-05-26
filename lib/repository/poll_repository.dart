import 'package:fenix/model/polls.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fenix/repository/database_init.dart';

class PollRepository {
  final DataBaseInit _dbHelper = DataBaseInit.instance;

  // ==================== CRUD ====================

  /// Сохранить событие (вставка или обновление)
  Future<void> save(Poll poll) async {
    final db = await _dbHelper.database;

    await db.insert('polls', {
      'id': poll.id,
      'meeting_id': poll.eventId,
      'title': poll.title,
      'url': poll.url,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Poll>> findAllByEventId(String eventId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> map = await db.query(
      "polls",
      where: "meeting_id = ?",
      whereArgs: [eventId],
    );

    return map.map((map) => Poll.fromMap(map)).toList();
  }

  Future<void> delete(String meetingId) async {
    final db = await _dbHelper.database;
    db.delete("polls", where: "meeting_id = ?", whereArgs: [meetingId]);
  }
}
