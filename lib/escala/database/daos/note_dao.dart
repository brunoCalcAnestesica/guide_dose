import 'package:sqflite/sqflite.dart';
import '../escala_database.dart';

class NoteDao {
  Future<Database> get _db => EscalaDatabase.instance.database;

  Future<void> insert(Map<String, dynamic> row) async {
    final db = await _db;
    await db.insert('notes', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertBatch(List<Map<String, dynamic>> rows) async {
    if (rows.isEmpty) return;
    final db = await _db;
    final batch = db.batch();
    for (final row in rows) {
      batch.insert('notes', row, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<Map<String, Map<String, dynamic>>> getByIdsMap(List<String> ids) async {
    if (ids.isEmpty) return {};
    final db = await _db;
    final result = <String, Map<String, dynamic>>{};
    for (var i = 0; i < ids.length; i += 500) {
      final chunk = ids.sublist(i, i + 500 > ids.length ? ids.length : i + 500);
      final placeholders = List.filled(chunk.length, '?').join(',');
      final rows = await db.query('notes', where: 'id IN ($placeholders)', whereArgs: chunk);
      for (final row in rows) {
        result[row['id'] as String] = row;
      }
    }
    return result;
  }

  Future<void> markSyncedBatch(List<String> ids) async {
    if (ids.isEmpty) return;
    final db = await _db;
    final batch = db.batch();
    for (final id in ids) {
      batch.update('notes', {'sync_status': 'synced'}, where: 'id = ?', whereArgs: [id]);
    }
    await batch.commit(noResult: true);
  }

  Future<void> update(String id, Map<String, dynamic> row) async {
    final db = await _db;
    await db.update('notes', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    final db = await _db;
    final rows = await db.query('notes', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> softDelete(String id) async {
    final db = await _db;
    await db.update(
      'notes',
      {'sync_status': 'deleted', 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getDeletedSync() async {
    final db = await _db;
    return db.query('notes', where: "sync_status = 'deleted'");
  }

  Future<void> hardDelete(String id) async {
    final db = await _db;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getByUser(String userId) async {
    final db = await _db;
    return db.query(
      'notes',
      where: "user_id = ? AND sync_status NOT IN ('deleted', 'archive_pending')",
      whereArgs: [userId],
      orderBy: 'updated_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getPendingSync() async {
    final db = await _db;
    return db.query('notes', where: "sync_status = 'pending'");
  }

  Future<void> markSynced(String id) async {
    final db = await _db;
    await db.update('notes', {'sync_status': 'synced'}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markArchivePending(String id) async {
    final db = await _db;
    await db.update(
      'notes',
      {'sync_status': 'archive_pending', 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getArchivePending() async {
    final db = await _db;
    return db.query('notes', where: "sync_status = 'archive_pending'");
  }
}
