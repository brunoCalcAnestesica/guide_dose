import 'package:sqflite/sqflite.dart';
import '../escala_database.dart';

class SyncMetaDao {
  Future<Database> get _db => EscalaDatabase.instance.database;

  Future<String?> get(String key) async {
    final db = await _db;
    final rows = await db.query('sync_meta', where: 'key = ?', whereArgs: [key]);
    if (rows.isEmpty) return null;
    return rows.first['value'] as String;
  }

  Future<void> set(String key, String value) async {
    final db = await _db;
    await db.insert(
      'sync_meta',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(String key) async {
    final db = await _db;
    await db.delete('sync_meta', where: 'key = ?', whereArgs: [key]);
  }
}
