import 'package:fenix/model/polls.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fenix/repository/database_Init.dart';

class PollRepository {
  final DataBaseInit _dbHelper = DataBaseInit.instance;

  // ==================== CRUD ====================

  /// Сохранить событие (вставка или обновление)
  Future<void> save(Poll poll) async {
    final db = await _dbHelper.database;

    await db.insert(
      'polls',
      {
        'id' : poll.id,
        'meeting_id': poll.eventId,   // или poll.meetingId — в зависимости от названия поля
        'title': poll.title,
        'url': poll.url,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
