import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class FileStorageService {
  static final FileStorageService _instance = FileStorageService._internal();

  factory FileStorageService() => _instance;

  FileStorageService._internal();

  // Базовые директории
  late Directory _appDirectory;
  late Directory _photosDirectory;
  late Directory _presentationsDirectory;

  // Инициализация директорий
  Future<void> init() async {
    _appDirectory = await getApplicationDocumentsDirectory();
    _photosDirectory = Directory(path.join(_appDirectory.path, 'photos'));
    _presentationsDirectory = Directory(
      path.join(_appDirectory.path, 'presentations'),
    );

    // Создаем директории, если их нет
    if (!await _photosDirectory.exists()) {
      await _photosDirectory.create(recursive: true);
    }
    if (!await _presentationsDirectory.exists()) {
      await _presentationsDirectory.create(recursive: true);
    }
  }

  // Сохранение фото
  Future<String?> savePhoto(String eventId, Uint8List? bytes) async {
    if (bytes == null) return null;

    final fileName = '${eventId}_photo.jpg';
    final file = File(path.join(_photosDirectory.path, fileName));
    await file.writeAsBytes(bytes);
    return file.path;
  }

  // Сохранение презентации
  Future<String?> savePresentation(String eventId, Uint8List? bytes) async {
    if (bytes == null) return null;

    final fileName = '${eventId}_presentation.pptx';
    final file = File(path.join(_presentationsDirectory.path, fileName));
    await file.writeAsBytes(bytes);
    return file.path;
  }

  // Загрузка фото из файла
  Future<Uint8List?> loadPhoto(String? filePath) async {
    if (filePath == null) return null;

    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
    } catch (e) {
      print('Ошибка загрузки фото: $e');
    }
    return null;
  }

  // Загрузка презентации из файла
  Future<Uint8List?> loadPresentation(String? filePath) async {
    if (filePath == null) return null;

    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
    } catch (e) {
      print('Ошибка загрузки презентации: $e');
    }
    return null;
  }

  // Удаление файлов мероприятия
  Future<void> deleteEventFiles(String eventId) async {
    try {
      final photoFile = File(
        path.join(_photosDirectory.path, '${eventId}_photo.jpg'),
      );
      if (await photoFile.exists()) {
        await photoFile.delete();
      }

      final presentationFile = File(
        path.join(_presentationsDirectory.path, '${eventId}_presentation.pptx'),
      );
      if (await presentationFile.exists()) {
        await presentationFile.delete();
      }
    } catch (e) {
      print('Ошибка удаления файлов: $e');
    }
  }
}
