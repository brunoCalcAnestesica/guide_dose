import 'package:sqflite/sqflite.dart';
import '../escala_database.dart';

class ShiftDao {
  Future<Database> get _db => EscalaDatabase.instance.database;

  Future<void> insert(Map<String, dynamic> row) async {
    final db = await _db;
    await db.insert('shifts', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertBatch(List<Map<String, dynamic>> rows) async {
    if (rows.isEmpty) return;
    final db = await _db;
    final batch = db.batch();
    for (final row in rows) {
      batch.insert('shifts', row, conflictAlgorithm: ConflictAlgorithm.replace);
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
      final rows = await db.query('shifts', where: 'id IN ($placeholders)', whereArgs: chunk);
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
      batch.update('shifts', {'sync_status': 'synced'}, where: 'id = ?', whereArgs: [id]);
    }
    await batch.commit(noResult: true);
  }

  Future<void> update(String id, Map<String, dynamic> row) async {
    final db = await _db;
    await db.update('shifts', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> getById(String id) async {
    final db = await _db;
    final rows = await db.query('shifts', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : rows.first;
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete('shifts', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> softDelete(String id) async {
    final db = await _db;
    await db.update(
      'shifts',
      {'sync_status': 'deleted', 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getDeletedSync() async {
    final db = await _db;
    return db.query('shifts', where: "sync_status = 'deleted'");
  }

  Future<void> hardDelete(String id) async {
    final db = await _db;
    await db.delete('shifts', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getByUser(String userId) async {
    final db = await _db;
    return db.query('shifts',
        where: "user_id = ? AND sync_status != 'deleted'",
        whereArgs: [userId],
        orderBy: 'date ASC, start_time ASC');
  }

  Future<List<Map<String, dynamic>>> getByUserAndDateRange(
      String userId, String fromDate, String toDate) async {
    final db = await _db;
    return db.query(
      'shifts',
      where: "user_id = ? AND date >= ? AND date <= ? AND sync_status != 'deleted'",
      whereArgs: [userId, fromDate, toDate],
      orderBy: 'date ASC, start_time ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getByUserAndMonth(
      String userId, int year, int month) async {
    final from = '$year-${month.toString().padLeft(2, '0')}-01';
    final lastDay = DateTime(year, month + 1, 0).day;
    final to = '$year-${month.toString().padLeft(2, '0')}-${lastDay.toString().padLeft(2, '0')}';
    return getByUserAndDateRange(userId, from, to);
  }

  Future<void> deleteBeforeDate(String userId, String beforeDate) async {
    final db = await _db;
    await db.delete(
      'shifts',
      where: 'user_id = ? AND date < ?',
      whereArgs: [userId, beforeDate],
    );
  }

  Future<List<Map<String, dynamic>>> getPendingSync() async {
    final db = await _db;
    return db.query('shifts', where: "sync_status = 'pending'");
  }

  Future<void> markSynced(String id) async {
    final db = await _db;
    await db.update('shifts', {'sync_status': 'synced'}, where: 'id = ?', whereArgs: [id]);
  }
}
