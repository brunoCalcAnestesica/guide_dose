import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/daos/blocked_day_dao.dart';
import '../database/daos/med_list_dao.dart';
import '../database/daos/note_dao.dart';
import '../database/daos/patient_dao.dart';
import '../database/daos/recurrence_dao.dart';
import '../database/daos/report_dao.dart';
import '../database/daos/shift_dao.dart';
import '../database/daos/sync_meta_dao.dart';
import '../../medicamento_unificado/lista_medicamentos_model.dart';
import '../models/blocked_day.dart';
import '../models/note.dart';
import '../models/patient.dart';
import '../models/recurrence_definition.dart';
import '../models/shift.dart';
import '../models/shift_report.dart';
import '../providers/blocked_day_provider.dart';
import '../providers/note_provider.dart';
import '../providers/patient_provider.dart';
import '../providers/recurrence_provider.dart';
import '../providers/report_provider.dart';
import '../providers/shift_provider.dart';

/// Bidirectional sync between local SQLite and Supabase.
///
/// Strategy: local-first — write to SQLite immediately, mark as 'pending',
/// then push to Supabase in background. On startup, pull only records
/// changed since the last sync (incremental).
class SupabaseSyncService {
  final ShiftDao _shiftDao = ShiftDao();
  final RecurrenceDao _recurrenceDao = RecurrenceDao();
  final ReportDao _reportDao = ReportDao();
  final BlockedDayDao _blockedDayDao = BlockedDayDao();
  final NoteDao _noteDao = NoteDao();
  final PatientDao _patientDao = PatientDao();
  final MedListDao _medListDao = MedListDao();
  final SyncMetaDao _syncMetaDao = SyncMetaDao();

  SupabaseClient get _client => Supabase.instance.client;
  String? get _userId => _client.auth.currentUser?.id;

  bool get isAvailable => _userId != null;

  // ───────── Retry helper ─────────

  Future<T> _withRetry<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    String label = 'operation',
  }) async {
    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        return await operation();
      } catch (e) {
        if (attempt == maxRetries) {
          debugPrint('$label failed after ${maxRetries + 1} attempts: $e');
          rethrow;
        }
        final delay = Duration(seconds: pow(2, attempt).toInt());
        debugPrint('$label attempt $attempt failed, retrying in ${delay.inSeconds}s: $e');
        await Future.delayed(delay);
      }
    }
    throw StateError('Unreachable');
  }

  // ───────── Push: local → Supabase (batch) ─────────

  Future<int> pushPendingChanges() async {
    if (!isAvailable) return 0;
    int synced = 0;

    synced += await _pushShifts();
    synced += await _pushRecurrenceRules();
    synced += await _pushReports();
    synced += await _pushBlockedDays();
    synced += await _pushNotes();
    synced += await _pushPatients();
    await _pushDeleted();
    await _pushArchivedNotes();
    await _pushArchivedPatients();

    return synced;
  }

  Future<int> _pushShifts() async {
    final pending = await _shiftDao.getPendingSync();
    if (pending.isEmpty) return 0;
    try {
      final rows = pending
          .map((r) => Shift.fromDbRow(r).toSupabaseRow(_userId!))
          .toList();
      await _withRetry(() => _client.from('shifts').upsert(rows), label: 'push shifts');
      await _shiftDao.markSyncedBatch(pending.map((r) => r['id'] as String).toList());
      return pending.length;
    } catch (e) {
      debugPrint('Batch push shifts error: $e');
      return 0;
    }
  }

  Future<int> _pushRecurrenceRules() async {
    final pending = await _recurrenceDao.getPendingSync();
    if (pending.isEmpty) return 0;
    try {
      final rows = pending
          .map((r) => RecurrenceDefinition.fromDbRow(r).toSupabaseRow(_userId!))
          .toList();
      await _withRetry(() => _client.from('recurrence_rules').upsert(rows), label: 'push recurrence');
      await _recurrenceDao.markSyncedBatch(pending.map((r) => r['id'] as String).toList());
      return pending.length;
    } catch (e) {
      debugPrint('Batch push recurrence rules error: $e');
      return 0;
    }
  }

  Future<int> _pushReports() async {
    final pending = await _reportDao.getPendingSync();
    if (pending.isEmpty) return 0;
    try {
      final rows = pending
          .map((r) => ShiftReport.fromDbRow(r).toSupabaseRow())
          .toList();
      await _withRetry(() => _client.from('shift_reports').upsert(rows), label: 'push reports');
      await _reportDao.markSyncedBatch(pending.map((r) => r['id'] as String).toList());
      return pending.length;
    } catch (e) {
      debugPrint('Batch push reports error: $e');
      return 0;
    }
  }

  Future<int> _pushBlockedDays() async {
    final pending = await _blockedDayDao.getPendingSync();
    if (pending.isEmpty) return 0;
    try {
      final rows = pending
          .map((r) => BlockedDay.fromDbRow(r).toSupabaseRow(_userId!))
          .toList();
      await _withRetry(() => _client.from('blocked_days').upsert(rows), label: 'push blocked days');
      await _blockedDayDao.markSyncedBatch(pending.map((r) => r['id'] as String).toList());
      return pending.length;
    } catch (e) {
      debugPrint('Batch push blocked days error: $e');
      return 0;
    }
  }

  Future<int> _pushNotes() async {
    final pending = await _noteDao.getPendingSync();
    if (pending.isEmpty) return 0;
    try {
      final rows = pending
          .map((r) => Note.fromDbRow(r).toSupabaseRow(_userId!))
          .toList();
      await _withRetry(() => _client.from('notes').upsert(rows), label: 'push notes');
      await _noteDao.markSyncedBatch(pending.map((r) => r['id'] as String).toList());
      return pending.length;
    } catch (e) {
      debugPrint('Batch push notes error: $e');
      return 0;
    }
  }

  Future<int> _pushPatients() async {
    final pending = await _patientDao.getPendingSync();
    if (pending.isEmpty) return 0;
    try {
      final rows = pending
          .map((r) => Patient.fromDbRow(r).toSupabaseRow(_userId!))
          .toList();
      await _withRetry(() => _client.from('patients').upsert(rows), label: 'push patients');
      await _patientDao.markSyncedBatch(pending.map((r) => r['id'] as String).toList());
      return pending.length;
    } catch (e) {
      debugPrint('Batch push patients error: $e');
      return 0;
    }
  }

  /// Push locally soft-deleted records to Supabase, then hard-delete them.
  Future<void> _pushDeleted() async {
    await _pushDeletedShifts();
    await _pushDeletedRecurrenceRules();
    await _pushDeletedReports();
    await _pushDeletedBlockedDays();
    await _pushDeletedNotes();
    await _pushDeletedPatients();
    await _pushDeletedMedLists();
  }

  Future<void> _pushDeletedShifts() async {
    final deleted = await _shiftDao.getDeletedSync();
    for (final row in deleted) {
      final id = row['id'] as String;
      try {
        await _withRetry(() => _client.from('shifts').delete().eq('id', id), label: 'delete shift');
        await _shiftDao.hardDelete(id);
      } catch (e) {
        debugPrint('Push deleted shift error: $e');
      }
    }
  }

  Future<void> _pushDeletedRecurrenceRules() async {
    final deleted = await _recurrenceDao.getDeletedSync();
    for (final row in deleted) {
      final id = row['id'] as String;
      try {
        await _withRetry(() => _client.from('recurrence_rules').delete().eq('id', id), label: 'delete recurrence');
        await _recurrenceDao.hardDelete(id);
      } catch (e) {
        debugPrint('Push deleted recurrence rule error: $e');
      }
    }
  }

  Future<void> _pushDeletedReports() async {
    final deleted = await _reportDao.getDeletedSync();
    for (final row in deleted) {
      final id = row['id'] as String;
      try {
        await _withRetry(() => _client.from('shift_reports').delete().eq('id', id), label: 'delete report');
        await _reportDao.hardDelete(id);
      } catch (e) {
        debugPrint('Push deleted report error: $e');
      }
    }
  }

  Future<void> _pushDeletedBlockedDays() async {
    final deleted = await _blockedDayDao.getDeletedSync();
    for (final row in deleted) {
      final id = row['id'] as String;
      try {
        await _withRetry(() => _client.from('blocked_days').delete().eq('id', id), label: 'delete blocked day');
        await _blockedDayDao.hardDelete(id);
      } catch (e) {
        debugPrint('Push deleted blocked day error: $e');
      }
    }
  }

  Future<void> _pushDeletedNotes() async {
    final deleted = await _noteDao.getDeletedSync();
    for (final row in deleted) {
      final id = row['id'] as String;
      try {
        await _withRetry(() => _client.from('notes').delete().eq('id', id), label: 'delete note');
        await _noteDao.hardDelete(id);
      } catch (e) {
        debugPrint('Push deleted note error: $e');
      }
    }
  }

  Future<void> _pushDeletedPatients() async {
    final deleted = await _patientDao.getDeletedSync();
    for (final row in deleted) {
      final id = row['id'] as String;
      try {
        await _withRetry(() => _client.from('patients').delete().eq('id', id), label: 'delete patient');
        await _patientDao.hardDelete(id);
      } catch (e) {
        debugPrint('Push deleted patient error: $e');
      }
    }
  }

  Future<void> _pushDeletedMedLists() async {
    final deleted = await _medListDao.getDeletedSync();
    for (final row in deleted) {
      final id = row['id'] as String;
      try {
        await _withRetry(
          () => _client.from('med_lists').delete().eq('id', id).eq('user_id', _userId!),
          label: 'delete med_list',
        );
        await _medListDao.hardDelete(id);
      } catch (e) {
        debugPrint('Push deleted med_list error: $e');
      }
    }
  }

  // ───────── Push archive_pending: local → Supabase archive ─────────

  Future<void> _pushArchivedNotes() async {
    final pending = await _noteDao.getArchivePending();
    for (final row in pending) {
      final id = row['id'] as String;
      try {
        final note = Note.fromDbRow(row);
        final archiveRow = note.toSupabaseRow(_userId!);
        archiveRow['archived_at'] = DateTime.now().toIso8601String();
        await _withRetry(() => _client.from('notes_archive').upsert(archiveRow), label: 'archive note');
        await _client.from('notes').delete().eq('id', id);
        await _noteDao.hardDelete(id);
      } catch (e) {
        debugPrint('Push archived note error: $e');
      }
    }
  }

  Future<void> _pushArchivedPatients() async {
    final pending = await _patientDao.getArchivePending();
    for (final row in pending) {
      final id = row['id'] as String;
      try {
        final patient = Patient.fromDbRow(row);
        final archiveRow = patient.toSupabaseRow(_userId!);
        archiveRow['archived_at'] = DateTime.now().toIso8601String();
        await _withRetry(() => _client.from('patients_archive').upsert(archiveRow), label: 'archive patient');
        await _client.from('patients').delete().eq('id', id);
        await _patientDao.hardDelete(id);
      } catch (e) {
        debugPrint('Push archived patient error: $e');
      }
    }
  }

  // ───────── Pull: Supabase → local (incremental, batch, paginated) ─────────

  static const int _pullPageSize = 500;

  Future<void> pullAll({
    required ShiftProvider shiftProvider,
    required RecurrenceProvider recurrenceProvider,
    required ReportProvider reportProvider,
    BlockedDayProvider? blockedDayProvider,
    NoteProvider? noteProvider,
    PatientProvider? patientProvider,
  }) async {
    if (!isAvailable) return;

    await _pullShifts();
    await _pullRecurrenceRules();
    await _pullReports();
    await _pullBlockedDays();
    await _pullNotes();
    await _pullPatients();
    await _pullMedLists();

    await shiftProvider.loadShifts();
    await recurrenceProvider.load();
    await reportProvider.loadReports();
    await blockedDayProvider?.reload();
    await noteProvider?.reload();
    await patientProvider?.reload();
  }

  Future<void> _pullShifts() async {
    try {
      final lastSync = await _syncMetaDao.get('last_sync_shifts');
      final syncStart = DateTime.now().toUtc().toIso8601String();

      int offset = 0;
      while (true) {
        var query = _client.from('shifts').select().eq('user_id', _userId!);
        if (lastSync != null) {
          query = query.gte('updated_at', lastSync);
        }
        final rows = await _withRetry(
          () => query.order('date').range(offset, offset + _pullPageSize - 1),
          label: 'pull shifts',
        );

        if (rows.isNotEmpty) {
          final remoteIds = rows.map((r) => r['id'] as String).toList();
          final localMap = await _shiftDao.getByIdsMap(remoteIds);
          final toInsert = <Map<String, dynamic>>[];

          for (final row in rows) {
            final remote = Shift.fromSupabaseRow(row);
            final local = localMap[remote.id];

            if (local != null) {
              final localStatus = local['sync_status'] as String?;
              if (localStatus == 'pending') {
                final localUpdated = local['updated_at'] != null
                    ? DateTime.parse(local['updated_at'] as String)
                    : DateTime(2000);
                if (localUpdated.isAfter(remote.updatedAt)) continue;
              }
            }

            final dbRow = remote.toDbRow(_userId!);
            dbRow['sync_status'] = 'synced';
            toInsert.add(dbRow);
          }

          await _shiftDao.insertBatch(toInsert);
        }

        if (rows.length < _pullPageSize) break;
        offset += _pullPageSize;
      }

      await _syncMetaDao.set('last_sync_shifts', syncStart);
    } catch (e) {
      debugPrint('Pull shifts error: $e');
    }
  }

  Future<void> _pullRecurrenceRules() async {
    try {
      final lastSync = await _syncMetaDao.get('last_sync_recurrence_rules');
      final syncStart = DateTime.now().toUtc().toIso8601String();

      int offset = 0;
      while (true) {
        var query = _client.from('recurrence_rules').select().eq('user_id', _userId!);
        if (lastSync != null) {
          query = query.gte('updated_at', lastSync);
        }
        final rows = await _withRetry(
          () => query.order('start_date').range(offset, offset + _pullPageSize - 1),
          label: 'pull recurrence',
        );

        if (rows.isNotEmpty) {
          final remoteIds = rows.map((r) => r['id'] as String).toList();
          final localMap = await _recurrenceDao.getByIdsMap(remoteIds);
          final toInsert = <Map<String, dynamic>>[];

          for (final row in rows) {
            final remote = RecurrenceDefinition.fromSupabaseRow(row);
            final local = localMap[remote.id];

            if (local != null) {
              final localStatus = local['sync_status'] as String?;
              if (localStatus == 'pending') {
                final localUpdated = local['updated_at'] != null
                    ? DateTime.parse(local['updated_at'] as String)
                    : DateTime(2000);
                if (localUpdated.isAfter(remote.updatedAt)) continue;
              }
            }

            final dbRow = remote.toDbRow(_userId!);
            dbRow['sync_status'] = 'synced';
            toInsert.add(dbRow);
          }

          await _recurrenceDao.insertBatch(toInsert);
        }

        if (rows.length < _pullPageSize) break;
        offset += _pullPageSize;
      }

      await _syncMetaDao.set('last_sync_recurrence_rules', syncStart);
    } catch (e) {
      debugPrint('Pull recurrence rules error: $e');
    }
  }

  Future<void> _pullReports() async {
    try {
      final lastSync = await _syncMetaDao.get('last_sync_reports');
      final syncStart = DateTime.now().toUtc().toIso8601String();

      int offset = 0;
      while (true) {
        var query = _client.from('shift_reports').select().eq('user_id', _userId!);
        if (lastSync != null) {
          query = query.gte('updated_at', lastSync);
        }
        final rows = await _withRetry(
          () => query.order('year').order('month').range(offset, offset + _pullPageSize - 1),
          label: 'pull reports',
        );

        if (rows.isNotEmpty) {
          final remoteIds = rows.map((r) => r['id'] as String).toList();
          final localMap = await _reportDao.getByIdsMap(remoteIds);
          final toInsert = <Map<String, dynamic>>[];

          for (final row in rows) {
            final remote = ShiftReport.fromSupabaseRow(row);
            final local = localMap[remote.id];

            if (local != null) {
              final localStatus = local['sync_status'] as String?;
              if (localStatus == 'pending') {
                final localUpdated = local['updated_at'] != null
                    ? DateTime.parse(local['updated_at'] as String)
                    : DateTime(2000);
                if (localUpdated.isAfter(remote.updatedAt)) continue;
              }
            }

            final dbRow = remote.toDbRow();
            dbRow['sync_status'] = 'synced';
            toInsert.add(dbRow);
          }

          await _reportDao.insertBatch(toInsert);
        }

        if (rows.length < _pullPageSize) break;
        offset += _pullPageSize;
      }

      await _syncMetaDao.set('last_sync_reports', syncStart);
    } catch (e) {
      debugPrint('Pull reports error: $e');
    }
  }

  Future<void> _pullBlockedDays() async {
    try {
      final lastSync = await _syncMetaDao.get('last_sync_blocked_days');
      final syncStart = DateTime.now().toUtc().toIso8601String();

      int offset = 0;
      while (true) {
        var query = _client.from('blocked_days').select().eq('user_id', _userId!);
        if (lastSync != null) {
          query = query.gte('updated_at', lastSync);
        }
        final rows = await _withRetry(
          () => query.order('date').range(offset, offset + _pullPageSize - 1),
          label: 'pull blocked days',
        );

        if (rows.isNotEmpty) {
          final remoteIds = rows.map((r) => r['id'] as String).toList();
          final localMap = await _blockedDayDao.getByIdsMap(remoteIds);
          final toInsert = <Map<String, dynamic>>[];

          for (final row in rows) {
            final remote = BlockedDay.fromSupabaseRow(row);
            final local = localMap[remote.id];

            if (local != null) {
              final localStatus = local['sync_status'] as String?;
              if (localStatus == 'pending') {
                final localUpdated = local['updated_at'] != null
                    ? DateTime.parse(local['updated_at'] as String)
                    : DateTime(2000);
                if (localUpdated.isAfter(remote.updatedAt)) continue;
              }
            }

            final dbRow = remote.toDbRow(_userId!);
            dbRow['sync_status'] = 'synced';
            toInsert.add(dbRow);
          }

          await _blockedDayDao.insertBatch(toInsert);
        }

        if (rows.length < _pullPageSize) break;
        offset += _pullPageSize;
      }

      await _syncMetaDao.set('last_sync_blocked_days', syncStart);
    } catch (e) {
      debugPrint('Pull blocked days error: $e');
    }
  }

  Future<void> _pullNotes() async {
    try {
      final lastSync = await _syncMetaDao.get('last_sync_notes');
      final syncStart = DateTime.now().toUtc().toIso8601String();

      int offset = 0;
      while (true) {
        var query = _client.from('notes').select().eq('user_id', _userId!);
        if (lastSync != null) {
          query = query.gte('updated_at', lastSync);
        }
        final rows = await _withRetry(
          () => query.order('updated_at').range(offset, offset + _pullPageSize - 1),
          label: 'pull notes',
        );

        if (rows.isNotEmpty) {
          final remoteIds = rows.map((r) => r['id'] as String).toList();
          final localMap = await _noteDao.getByIdsMap(remoteIds);
          final toInsert = <Map<String, dynamic>>[];

          for (final row in rows) {
            final remote = Note.fromSupabaseRow(row);
            final local = localMap[remote.id];

            if (local != null) {
              final localStatus = local['sync_status'] as String?;
              if (localStatus == 'pending') {
                final localUpdated = local['updated_at'] != null
                    ? DateTime.parse(local['updated_at'] as String)
                    : DateTime(2000);
                if (localUpdated.isAfter(remote.updatedAt)) continue;
              }
            }

            final dbRow = remote.toDbRow(_userId!);
            dbRow['sync_status'] = 'synced';
            toInsert.add(dbRow);
          }

          await _noteDao.insertBatch(toInsert);
        }

        if (rows.length < _pullPageSize) break;
        offset += _pullPageSize;
      }

      await _syncMetaDao.set('last_sync_notes', syncStart);
    } catch (e) {
      debugPrint('Pull notes error: $e');
    }
  }

  Future<void> _pullPatients() async {
    try {
      final lastSync = await _syncMetaDao.get('last_sync_patients');
      final syncStart = DateTime.now().toUtc().toIso8601String();

      int offset = 0;
      while (true) {
        var query = _client.from('patients').select().eq('user_id', _userId!);
        if (lastSync != null) {
          query = query.gte('updated_at', lastSync);
        }
        final rows = await _withRetry(
          () => query.order('updated_at').range(offset, offset + _pullPageSize - 1),
          label: 'pull patients',
        );

        if (rows.isNotEmpty) {
          final remoteIds = rows.map((r) => r['id'] as String).toList();
          final localMap = await _patientDao.getByIdsMap(remoteIds);
          final toInsert = <Map<String, dynamic>>[];

          for (final row in rows) {
            final remote = Patient.fromSupabaseRow(row);
            final local = localMap[remote.id];

            if (local != null) {
              final localStatus = local['sync_status'] as String?;
              if (localStatus == 'pending') {
                final localUpdated = local['updated_at'] != null
                    ? DateTime.parse(local['updated_at'] as String)
                    : DateTime(2000);
                if (localUpdated.isAfter(remote.updatedAt)) continue;
              }
            }

            final dbRow = remote.toDbRow(_userId!);
            dbRow['sync_status'] = 'synced';
            toInsert.add(dbRow);
          }

          await _patientDao.insertBatch(toInsert);
        }

        if (rows.length < _pullPageSize) break;
        offset += _pullPageSize;
      }

      await _syncMetaDao.set('last_sync_patients', syncStart);
    } catch (e) {
      debugPrint('Pull patients error: $e');
    }
  }

  Future<void> _pullMedLists() async {
    try {
      final lastSync = await _syncMetaDao.get('last_sync_med_lists');
      final syncStart = DateTime.now().toUtc().toIso8601String();

      int offset = 0;
      while (true) {
        var query = _client.from('med_lists').select().eq('user_id', _userId!);
        if (lastSync != null) {
          query = query.gte('updated_at', lastSync);
        }
        final rows = await _withRetry(
          () => query.order('updated_at').range(offset, offset + _pullPageSize - 1),
          label: 'pull med_lists',
        );

        if (rows.isNotEmpty) {
          final remoteIds = rows.map((r) => r['id'] as String).toList();
          final localMap = await _medListDao.getByIdsMap(remoteIds);
          final toInsert = <Map<String, dynamic>>[];

          for (final row in rows) {
            final remote = ListaMedicamentosCustom.fromSupabaseRow(row);
            final local = localMap[remote.id];

            if (local != null) {
              final localStatus = local['sync_status'] as String?;
              if (localStatus == 'pending') {
                final localUpdated = local['updated_at'] != null
                    ? DateTime.parse(local['updated_at'] as String)
                    : DateTime(2000);
                if (localUpdated.isAfter(remote.updatedAt)) continue;
              }
            }

            final dbRow = remote.toDbRow(_userId!);
            dbRow['sync_status'] = 'synced';
            toInsert.add(dbRow);
          }

          await _medListDao.insertBatch(toInsert);
        }

        if (rows.length < _pullPageSize) break;
        offset += _pullPageSize;
      }

      await _syncMetaDao.set('last_sync_med_lists', syncStart);
    } catch (e) {
      debugPrint('Pull med_lists error: $e');
    }
  }
}
