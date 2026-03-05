import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../database/daos/recurrence_dao.dart';
import '../models/recurrence_definition.dart';
import '../models/recurrence_rule.dart';
import '../models/shift.dart';
import '../services/supabase_sync_service.dart';

class RecurrenceProvider extends ChangeNotifier {
  final RecurrenceDao _dao = RecurrenceDao();
  final SupabaseSyncService _syncService = SupabaseSyncService();
  final Uuid _uuid = const Uuid();

  List<RecurrenceDefinition> _rules = [];
  bool _isLoading = false;
  int _version = 0;

  List<RecurrenceDefinition> get rules => List.unmodifiable(_rules);
  bool get isLoading => _isLoading;
  /// Incremented on every mutation; used by Selectors to detect changes
  /// that don't alter the list length (e.g. excludedDates updates).
  int get version => _version;

  String get _userId =>
      Supabase.instance.client.auth.currentUser?.id ?? 'local';

  void _notifyChanged() {
    _version++;
    notifyListeners();
  }

  void _syncInBackground() {
    _syncService.pushPendingChanges().catchError((e) {
      debugPrint('Background sync error: $e');
      return 0;
    });
  }

  // ───────── Load ─────────

  Future<void> load() async {
    _isLoading = true;
    _notifyChanged();

    try {
      final rows = await _dao.getByUser(_userId);
      _rules = rows.map((r) => RecurrenceDefinition.fromDbRow(r)).toList();
    } catch (e) {
      debugPrint('RecurrenceProvider.load error: $e');
    }

    _isLoading = false;
    _notifyChanged();
  }

  // ───────── CRUD ─────────

  Future<RecurrenceDefinition> add({
    required String hospitalName,
    required DateTime startDate,
    required String startTime,
    required String endTime,
    required double durationHours,
    required double value,
    required String type,
    String? informations,
    bool isAllDay = false,
    required RecurrenceRule rule,
  }) async {
    final now = DateTime.now();
    final def = RecurrenceDefinition(
      id: _uuid.v4(),
      hospitalName: hospitalName,
      startDate: startDate,
      startTime: startTime,
      endTime: endTime,
      durationHours: durationHours,
      value: value,
      type: type,
      informations: informations,
      isAllDay: isAllDay,
      rule: rule,
      createdAt: now,
      updatedAt: now,
    );

    await _dao.insert(def.toDbRow(_userId));
    _rules.add(def);
    _notifyChanged();
    _syncInBackground();
    return def;
  }

  Future<void> update(RecurrenceDefinition def) async {
    final updated = def.copyWith(updatedAt: DateTime.now());
    await _dao.update(updated.id, updated.toDbRow(_userId));
    final idx = _rules.indexWhere((r) => r.id == updated.id);
    if (idx != -1) {
      _rules[idx] = updated;
    }
    _notifyChanged();
    _syncInBackground();
  }

  /// "Excluir este e os próximos": sets endDate to the day BEFORE [fromDate].
  /// The rule stays in the DB until cleanup removes it.
  Future<void> interruptFromDate(String ruleId, DateTime fromDate) async {
    final endDate = fromDate.subtract(const Duration(days: 1));
    final iso = _dateToIso(endDate);
    await _dao.setEndDate(ruleId, iso);

    final idx = _rules.indexWhere((r) => r.id == ruleId);
    if (idx != -1) {
      _rules[idx] = _rules[idx].copyWith(
        endDate: endDate,
        updatedAt: DateTime.now(),
      );
    }
    _notifyChanged();
    _syncInBackground();
  }

  /// Adds [date] to the rule's excluded dates list, so that single
  /// occurrence is skipped without affecting the rest of the series.
  Future<void> addExclusion(String ruleId, DateTime date) async {
    final idx = _rules.indexWhere((r) => r.id == ruleId);
    if (idx == -1) return;

    final updated = _rules[idx].copyWith(
      excludedDates: [..._rules[idx].excludedDates, date],
      updatedAt: DateTime.now(),
    );
    await _dao.update(updated.id, updated.toDbRow(_userId));
    _rules[idx] = updated;
    _notifyChanged();
    _syncInBackground();
  }

  /// Toggles the paid status for a single occurrence within a recurring series.
  Future<void> togglePaid(String ruleId, DateTime date) async {
    final idx = _rules.indexWhere((r) => r.id == ruleId);
    if (idx == -1) return;

    final rule = _rules[idx];
    final isoDate = _dateToIso(date);
    final alreadyPaid = rule.paidDates.any((d) => _dateToIso(d) == isoDate);

    final newPaidDates = alreadyPaid
        ? rule.paidDates.where((d) => _dateToIso(d) != isoDate).toList()
        : [...rule.paidDates, date];

    final updated = rule.copyWith(
      paidDates: newPaidDates,
      updatedAt: DateTime.now(),
    );
    await _dao.update(updated.id, updated.toDbRow(_userId));
    _rules[idx] = updated;
    _notifyChanged();
    _syncInBackground();
  }

  /// "Excluir todos da série": soft-deletes the rule and pushes to Supabase.
  Future<void> deleteAll(String ruleId) async {
    await _dao.softDelete(ruleId);
    _rules.removeWhere((r) => r.id == ruleId);
    _notifyChanged();
    _syncInBackground();
  }

  /// Removes rules whose endDate is before the cutoff (used by ArchiveService).
  Future<void> cleanupExpired(DateTime cutoffDate) async {
    await _dao.deleteExpiredBefore(_userId, _dateToIso(cutoffDate));
    _rules.removeWhere(
        (r) => r.endDate != null && r.endDate!.isBefore(cutoffDate));
    _notifyChanged();
  }

  // ───────── Query: virtual occurrences ─────────

  /// Generates virtual [Shift] objects from all active rules for a given month.
  List<Shift> getOccurrencesForMonth(int year, int month) {
    final rangeStart = DateTime(year, month, 1);
    final rangeEnd = DateTime(year, month + 1, 0);
    return _generateInRange(rangeStart, rangeEnd);
  }

  /// Generates virtual [Shift] objects from all active rules for a given date.
  List<Shift> getOccurrencesForDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return _generateInRange(day, day);
  }

  /// Generates virtual [Shift] objects for a date range.
  List<Shift> getOccurrencesForRange(DateTime rangeStart, DateTime rangeEnd) {
    return _generateInRange(rangeStart, rangeEnd);
  }

  List<Shift> _generateInRange(DateTime rangeStart, DateTime rangeEnd) {
    final shifts = <Shift>[];
    for (final def in _rules) {
      final paidSet = def.paidDates.map(_dateToIso).toSet();
      final dates = def.getOccurrencesInRange(rangeStart, rangeEnd);
      for (final date in dates) {
        shifts.add(Shift(
          id: '${def.id}_${_dateToIso(date)}',
          hospitalName: def.hospitalName,
          date: date,
          startTime: def.startTime,
          endTime: def.endTime,
          durationHours: def.durationHours,
          value: def.value,
          type: def.type,
          informations: def.informations,
          isAllDay: def.isAllDay,
          isCompleted: paidSet.contains(_dateToIso(date)),
          createdAt: def.createdAt,
          sourceRecurrenceId: def.id,
        ));
      }
    }
    shifts.sort((a, b) {
      final dc = a.date.compareTo(b.date);
      return dc != 0 ? dc : a.startTime.compareTo(b.startTime);
    });
    return shifts;
  }

  // ───────── Helpers ─────────

  List<String> getHospitalSuggestions() {
    return _rules
        .where((r) => r.hospitalName.isNotEmpty)
        .map((r) => r.hospitalName)
        .toSet()
        .toList()
      ..sort();
  }

  RecurrenceDefinition? getById(String id) {
    for (final r in _rules) {
      if (r.id == id) return r;
    }
    return null;
  }

  static String _dateToIso(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
