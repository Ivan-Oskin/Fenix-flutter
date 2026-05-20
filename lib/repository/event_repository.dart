import 'package:fenix/repository/file_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fenix/model/event.dart';
import 'package:fenix/repository/database_init.dart';

class EventRepository {
  final DataBaseInit _dbHelper = DataBaseInit.instance;
  final FileStorageService _storage = FileStorageService();

  // ==================== CRUD ====================

  /// Сохранить событие (вставка или обновление)
  Future<void> saveEvent(Event event) async {
    final db = await _dbHelper.database;

    // Сохраняем файлы и получаем пути
    final photoPath = await _storage.savePhoto(event.id!, event.photoBytes);
    final presentationPath = await _storage.savePresentation(event.id!, event.presentationBytes);

    // Сохраняем только пути в БД
    await db.insert('event', {
      'id': event.id,
      'title': event.title,
      'description': event.description,
      'location': event.location,
      'start_date': event.startDate,
      'speaker_id': event.speakerId,
      'photo_path': photoPath,      // Путь к файлу фото
      'presentation_path': presentationPath, // Путь к файлу презентации
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Получение всех событий (с загрузкой файлов)
  Future<List<Event>> findAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      "event",
      orderBy: "start_date DESC",
    );

    final List<Event> events = [];

    for (var map in maps) {
      final event = Event.fromMap(map);

      // Загружаем файлы по путям
      event.photoBytes = await _storage.loadPhoto(map['photo_path']);
      event.presentationBytes = await _storage.loadPresentation(map['presentation_path']);

      events.add(event);
    }

    return events;
  }

  // Поиск по ID (с загрузкой файлов)
  Future<Event?> findById(String id) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      "event",
      where: "id = ?",
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final event = Event.fromMap(maps.first);

      // Загружаем файлы по путям
      event.photoBytes = await _storage.loadPhoto(maps.first['photo_path']);
      event.presentationBytes = await _storage.loadPresentation(maps.first['presentation_path']);

      return event;
    }

    return null;
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
