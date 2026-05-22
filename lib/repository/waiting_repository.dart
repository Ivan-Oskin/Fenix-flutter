import 'package:sqflite/sqflite.dart';
import 'package:fenix/repository/database_init.dart';

class WaitingRepository {
  final DataBaseInit dataBaseInit = DataBaseInit.instance;

  Future<void> save(String id) async {
    final db = await DataBaseInit.instance.database;
    await db.insert('wait_list', {
      'id': id,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<String>> get() async {
    final db = await DataBaseInit.instance.database;

    final List<Map<String, dynamic>> maps = await db.query("wait_list");
    return maps.map((row) => row['id'] as String).toList();
  }

  Future<void> delete(String id) async {
    final db = await DataBaseInit.instance.database;
    await db.delete('wait_list', where: "id = ?", whereArgs: [id]);
  }
}
