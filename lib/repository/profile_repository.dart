import 'package:fenix/model/profile.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fenix/repository/database_Init.dart';

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

  Future<int> insertProfile(Profile profile) async {
    final db = await dataBaseInit.database;
    return await db.insert("profile", profile.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Profile?> getProfile() async {
    final db = await dataBaseInit.database;
    final result = await db.query("profile", limit: 1);

    if(result.isNotEmpty) {
      return Profile.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateProfile(Profile profile) async {
    final db = await dataBaseInit.database;
    return await db.update(
      'profile',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }
}