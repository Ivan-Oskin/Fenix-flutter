import 'package:fenix/model/profile.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fenix/repository/database_init.dart';

class ProfileRepository {
  final DataBaseInit dataBaseInit = DataBaseInit.instance;

  Future<bool> isProfileEmpty() async {
    try {
      final db = await DataBaseInit.instance.database;
      final List<Map<String, dynamic>> result = await db.query('profile');
      return result.isEmpty;
    } catch (e) {
      return true; // Если ошибка, показываем страницу регистрации
    }
  }

  Future<void> save(Profile profile) async {
    final db = await DataBaseInit.instance.database;
    await db.insert('profile', {
      'id': profile.id,
      'username': profile.username,
      'token': profile.token,
      'name': profile.name,
      'surname': profile.surname,
      'patronymic': profile.patronymic,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
