import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../database/daos/shift_dao.dart';
import '../models/shift.dart';
import '../services/calendar_sync_service.dart';
import '../services/supabase_sync_service.dart';
import '../services/widget_service.dart';
import '../utils/formatters.dart';

class ShiftProvider extends ChangeNotifier {
  final CalendarSyncService _calendarSync = CalendarSyncService();
  final SupabaseSyncService _syncService = SupabaseSyncService();
  final ShiftDao _dao = ShiftDao();
  final Uuid _uuid = const Uuid();

  static const Map<String, List<String>> _defaultTimesByType = {
    'Diurno': ['07:00', '19:00'],
    'Noturno': ['19:00', '07:00'],
    '24h': ['07:00', '07:00'],
    'Manhã': ['07:00', '13:00'],
    'Tarde': ['13:00', '19:00'],
    'Cinderela': ['19:00', '01:00'],
    'Procedimento': ['08:00', '12:00'],
  };
  static const String _legacyDefaultStart = '07:00';
  static const String _legacyDefaultEnd = '19:00';

  List<Shift> _shifts = [];
  bool _isLoading = false;
  Map<String, List<Shift>> _byMonth = {};
  Map<String, List<Shift>> _byDate = {};
  final Set<String> _loadedMonths = {};

  List<Shift> get shifts => _shifts;
  bool get isLoading => _isLoading;

  String get _userId =>
      Supabase.instance.client.auth.currentUser?.id ?? 'local';

  List<String> getHospitalSuggestions() {
    return _shifts
        .where((s) => s.hospitalName.isNotEmpty)
        .map((s) => s.hospitalName)
        .toSet()
        .toList()
      ..sort();
  }

  // ───────── Indexes ─────────

  void _rebuildIndexes() {
    _byMonth.clear();
    _byDate.clear();
    for (final s in _shifts) {
      final y = s.date.year;
      final m = s.date.month;
      final d = s.date.day;
      _byMonth.putIfAbsent('$y-$m', () => []).add(s);
      _byDate.putIfAbsent('$y-$m-$d', () => []).add(s);
    }
    for (final list in _byMonth.values) {
      list.sort(_compareShiftsChronologically);
    }
    for (final list in _byDate.values) {
      list.sort(_compareShiftsChronologically);
    }
  }

  int _minutesFromTime(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return 0;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return (hour * 60) + minute;
  }

  int _compareShiftsChronologically(Shift a, Shift b) {
    final dateCompare = a.date.compareTo(b.date);
    if (dateCompare != 0) return dateCompare;

    final startCompare =
        _minutesFromTime(a.startTime).compareTo(_minutesFromTime(b.startTime));
    if (startCompare != 0) return startCompare;

    final endCompare =
        _minutesFromTime(a.endTime).compareTo(_minutesFromTime(b.endTime));
    if (endCompare != 0) return endCompare;

    return a.createdAt.compareTo(b.createdAt);
  }

  void _notifyAndUpdateWidget() {
    notifyListeners();
    WidgetService.scheduleUpdate();
  }

  void _syncInBackground() {
    _syncService.pushPendingChanges().catchError((e) {
      debugPrint('Background sync error: $e');
      return 0;
    });
  }

  // ───────── Load ─────────

  Future<void> loadShifts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final from = DateTime(now.year, now.month - 3, 1);
      final to = DateTime(now.year, now.month + 2, 0);
      final fromStr = '${from.year}-${from.month.toString().padLeft(2, '0')}-01';
      final toStr = '${to.year}-${to.month.toString().padLeft(2, '0')}-${to.day.toString().padLeft(2, '0')}';

      final rows = await _dao.getByUserAndDateRange(_userId, fromStr, toStr);
      _shifts = rows.map((r) => Shift.fromDbRow(r)).toList();
      _normalizeExistingShiftTimes();

      _loadedMonths.clear();
      for (var d = from; !d.isAfter(to); d = DateTime(d.year, d.month + 1, 1)) {
        _loadedMonths.add('${d.year}-${d.month}');
      }
    } catch (e) {
      debugPrint('ShiftProvider.loadShifts error: $e');
    }

    _shifts.sort(_compareShiftsChronologically);
    _rebuildIndexes();
    WidgetService.scheduleUpdate();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> ensureMonthLoaded(int year, int month) async {
    final key = '$year-$month';
    if (_loadedMonths.contains(key)) return;
    _loadedMonths.add(key);


    try {
      final rows = await _dao.getByUserAndMonth(_userId, year, month);
      final newShifts = rows.map((r) => Shift.fromDbRow(r)).toList();
      final existingIds = _shifts.map((s) => s.id).toSet();
      final toAdd = newShifts.where((s) => !existingIds.contains(s.id)).toList();
      if (toAdd.isNotEmpty) {
        _shifts.addAll(toAdd);
        _shifts.sort(_compareShiftsChronologically);
        _rebuildIndexes();
        _notifyAndUpdateWidget();
      }
    } catch (e) {
      debugPrint('ensureMonthLoaded error: $e');
    }
  }

  Future<void> ensureYearLoaded(int year) async {
    for (var m = 1; m <= 12; m++) {
      await ensureMonthLoaded(year, m);
    }
  }

  Future<void> syncChanges() async {
    // placeholder for future Supabase sync
  }

  // ───────── Normalization ─────────

  bool _isValidTime(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return false;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return false;
    return hour >= 0 && hour <= 23 && minute >= 0 && minute <= 59;
  }

  bool _isLegacyDefaultPair(Shift shift) {
    return shift.startTime == _legacyDefaultStart &&
        shift.endTime == _legacyDefaultEnd;
  }

  int _normalizeExistingShiftTimes() {
    int updatedCount = 0;
    for (int i = 0; i < _shifts.length; i++) {
      final shift = _shifts[i];
      final defaults = _defaultTimesByType[shift.type];
      if (defaults == null || defaults.length < 2) continue;

      final defaultStart = defaults[0];
      final defaultEnd = defaults[1];
      if (shift.startTime == defaultStart && shift.endTime == defaultEnd) {
        continue;
      }

      final hasValidTimes =
          _isValidTime(shift.startTime) && _isValidTime(shift.endTime);
      if (hasValidTimes && !_isLegacyDefaultPair(shift)) continue;

      final updated = shift.copyWith(
        startTime: defaultStart,
        endTime: defaultEnd,
        durationHours:
            AppFormatters.calculateDurationHours(defaultStart, defaultEnd),
      );
      _shifts[i] = updated;
      updatedCount++;
    }
    return updatedCount;
  }

  // ───────── Query ─────────

  List<Shift> getByDate(DateTime date) {
    final key = '${date.year}-${date.month}-${date.day}';
    final list = _byDate[key];
    return list != null ? List<Shift>.from(list) : <Shift>[];
  }

  List<Shift> getByMonth(int year, int month) {
    final key = '$year-$month';
    final list = _byMonth[key];
    return list != null ? List<Shift>.from(list) : <Shift>[];
  }

  List<Shift> getByDateRange(DateTime start, DateTime end) {
    final startNorm = DateTime(start.year, start.month, start.day);
    final endNorm = DateTime(end.year, end.month, end.day);
    final rangeShifts = _shifts.where((s) {
      final d = DateTime(s.date.year, s.date.month, s.date.day);
      return (d.isAtSameMomentAs(startNorm) || d.isAfter(startNorm)) &&
          (d.isAtSameMomentAs(endNorm) || d.isBefore(endNorm));
    }).toList();
    rangeShifts.sort(_compareShiftsChronologically);
    return rangeShifts;
  }

  List<Shift> getByHospital(String hospitalName) {
    final hospitalShifts =
        _shifts.where((s) => s.hospitalName == hospitalName).toList();
    hospitalShifts.sort(_compareShiftsChronologically);
    return hospitalShifts;
  }

  double getTotalHoursForMonth(int year, int month) {
    return getByMonth(year, month)
        .fold(0.0, (sum, s) => sum + s.durationHours);
  }

  double getCompletedHoursForMonth(int year, int month) {
    return getByMonth(year, month)
        .where((s) => s.isCompleted)
        .fold(0.0, (sum, s) => sum + s.durationHours);
  }

  double getTotalValueForMonth(int year, int month) {
    return getByMonth(year, month).fold(0.0, (sum, s) => sum + s.value);
  }

  double getCompletedValueForMonth(int year, int month) {
    return getByMonth(year, month)
        .where((s) => s.isCompleted)
        .fold(0.0, (sum, s) => sum + s.value);
  }

  double getPendingValueForMonth(int year, int month) {
    return getByMonth(year, month)
        .where((s) => !s.isCompleted)
        .fold(0.0, (sum, s) => sum + s.value);
  }

  double getCompletionPercentage(int year, int month) {
    final monthShifts = getByMonth(year, month);
    if (monthShifts.isEmpty) return 0;
    final completed = monthShifts.where((s) => s.isCompleted).length;
    return (completed / monthShifts.length) * 100;
  }

  List<Shift> getByYear(int year) {
    final yearShifts = _shifts.where((s) => s.date.year == year).toList();
    yearShifts.sort(_compareShiftsChronologically);
    return yearShifts;
  }

  double getTotalHoursForYear(int year) =>
      getByYear(year).fold(0.0, (sum, s) => sum + s.durationHours);

  double getTotalValueForYear(int year) =>
      getByYear(year).fold(0.0, (sum, s) => sum + s.value);

  double getCompletedValueForYear(int year) => getByYear(year)
      .where((s) => s.isCompleted)
      .fold(0.0, (sum, s) => sum + s.value);

  double getPendingValueForYear(int year) => getByYear(year)
      .where((s) => !s.isCompleted)
      .fold(0.0, (sum, s) => sum + s.value);

  Set<DateTime> getDaysWithShifts(int year, int month) {
    return getByMonth(year, month)
        .map((s) => DateTime(s.date.year, s.date.month, s.date.day))
        .toSet();
  }

  // ───────── CRUD ─────────

  Future<void> addShift({
    required String hospitalName,
    required DateTime date,
    required String startTime,
    required String endTime,
    required double durationHours,
    required double value,
    required String type,
    bool isAllDay = false,
    bool isCompleted = false,
    String? informations,
  }) async {
    final now = DateTime.now();
    final shift = Shift(
      id: _uuid.v4(),
      hospitalName: hospitalName,
      date: date,
      startTime: startTime,
      endTime: endTime,
      durationHours: durationHours,
      value: value,
      type: type,
      isAllDay: isAllDay,
      isCompleted: isCompleted,
      informations: informations,
      createdAt: now,
      updatedAt: now,
    );

    await _dao.insert(shift.toDbRow(_userId));
    _shifts.add(shift);
    _shifts.sort(_compareShiftsChronologically);
    _rebuildIndexes();
    _notifyAndUpdateWidget();
    _calendarSync.addEvent(shift, hospitalName);
    _syncInBackground();
  }

  Future<void> updateShift(Shift shift) async {
    final updated = shift.copyWith(updatedAt: DateTime.now());
    await _dao.update(updated.id, updated.toDbRow(_userId));
    final index = _shifts.indexWhere((s) => s.id == updated.id);
    if (index != -1) {
      _shifts[index] = updated;
      _shifts.sort(_compareShiftsChronologically);
      _rebuildIndexes();
    }
    _notifyAndUpdateWidget();
    _calendarSync.updateEvent(updated, updated.hospitalName);
    _syncInBackground();
  }

  Future<void> toggleCompleted(String id) async {
    final index = _shifts.indexWhere((s) => s.id == id);
    if (index != -1) {
      final updated = _shifts[index].copyWith(
        isCompleted: !_shifts[index].isCompleted,
        updatedAt: DateTime.now(),
      );
      _shifts[index] = updated;
      await _dao.update(id, updated.toDbRow(_userId));
      _rebuildIndexes();
      _notifyAndUpdateWidget();
      _syncInBackground();
    }
  }

  Future<void> deleteShift(String id) async {
    await _dao.softDelete(id);
    _shifts.removeWhere((s) => s.id == id);
    _rebuildIndexes();
    _notifyAndUpdateWidget();
    _calendarSync.deleteEvent(id);
    _syncInBackground();
  }

  /// Used by ArchiveService to remove shifts older than the cutoff.
  Future<void> deleteShiftsBefore(DateTime cutoffDate) async {
    final iso =
        '${cutoffDate.year}-${cutoffDate.month.toString().padLeft(2, '0')}-${cutoffDate.day.toString().padLeft(2, '0')}';
    await _dao.deleteBeforeDate(_userId, iso);
    _shifts.removeWhere((s) => s.date.isBefore(cutoffDate));
    _rebuildIndexes();
    _notifyAndUpdateWidget();
  }
}
