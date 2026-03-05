import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../database/daos/blocked_day_dao.dart';
import '../models/blocked_day.dart';
import '../services/supabase_sync_service.dart';

class BlockedDayProvider extends ChangeNotifier {
  static const int _maxFutureMonths = 12;

  final BlockedDayDao _dao = BlockedDayDao();
  final SupabaseSyncService _syncService = SupabaseSyncService();
  final Uuid _uuid = const Uuid();

  List<BlockedDay> _items = [];
  bool _loaded = false;

  final Map<String, BlockedDay> _byDate = {};

  List<BlockedDay> get items => List.unmodifiable(_items);

  String get _userId =>
      Supabase.instance.client.auth.currentUser?.id ?? 'local';

  void _rebuildByDate() {
    _byDate.clear();
    for (final b in _items) {
      final k = '${b.date.year}-${b.date.month}-${b.date.day}';
      _byDate[k] = b;
    }
  }

  static DateTime get _windowEnd {
    final n = DateTime.now();
    return DateTime(n.year, n.month + _maxFutureMonths, n.day);
  }

  static DateTime get _addMinDate {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  void _syncInBackground() {
    _syncService.pushPendingChanges().catchError((e) {
      debugPrint('BlockedDay background sync error: $e');
      return 0;
    });
  }

  Future<void> reload() async {
    _loaded = false;
    await load();
  }

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final rows = await _dao.getByUser(_userId);
      _items = rows.map((r) => BlockedDay.fromDbRow(r)).toList();
    } catch (e) {
      debugPrint('BlockedDayProvider.load error: $e');
    }
    _rebuildByDate();
    notifyListeners();
  }

  Map<DateTime, String> getForMonth(int year, int month) {
    final result = <DateTime, String>{};
    for (final b in _items) {
      if (b.date.year == year && b.date.month == month) {
        final day = DateTime(year, month, b.date.day);
        result[day] = b.label;
      }
    }
    return result;
  }

  BlockedDay? getForDate(DateTime date) {
    final k = '${date.year}-${date.month}-${date.day}';
    return _byDate[k];
  }

  Future<void> add(DateTime date, String label) async {
    await load();
    final day = DateTime(date.year, date.month, date.day);
    if (day.isBefore(_addMinDate) || day.isAfter(_windowEnd)) return;
    final now = DateTime.now();
    final b = BlockedDay(
      id: _uuid.v4(),
      date: day,
      label: label.isEmpty ? 'Feriado' : label,
      createdAt: now,
      updatedAt: now,
    );
    await _dao.insert(b.toDbRow(_userId));
    _items.add(b);
    _rebuildByDate();
    notifyListeners();
    _syncInBackground();
  }

  Future<void> addRange(DateTime start, DateTime end, String label) async {
    await load();
    final startDay = DateTime(start.year, start.month, start.day);
    var endDay = DateTime(end.year, end.month, end.day);
    if (endDay.isBefore(startDay)) return;
    if (startDay.isBefore(_addMinDate)) return;
    if (endDay.isAfter(_windowEnd)) endDay = _windowEnd;
    final effectiveLabel = label.isEmpty ? 'Feriado' : label;
    final now = DateTime.now();
    var current = startDay;
    while (!current.isAfter(endDay)) {
      final b = BlockedDay(
        id: _uuid.v4(),
        date: current,
        label: effectiveLabel,
        createdAt: now,
        updatedAt: now,
      );
      await _dao.insert(b.toDbRow(_userId));
      _items.add(b);
      current = DateTime(current.year, current.month, current.day + 1);
    }
    _rebuildByDate();
    notifyListeners();
    _syncInBackground();
  }

  Future<void> remove(String id) async {
    await load();
    await _dao.softDelete(id);
    _items.removeWhere((b) => b.id == id);
    _rebuildByDate();
    notifyListeners();
    _syncInBackground();
  }

  Future<void> deleteBlockedDaysBefore(DateTime cutoffDate) async {
    final iso =
        '${cutoffDate.year}-${cutoffDate.month.toString().padLeft(2, '0')}-${cutoffDate.day.toString().padLeft(2, '0')}';
    await _dao.deleteBeforeDate(_userId, iso);
    _items.removeWhere((b) => b.date.isBefore(cutoffDate));
    _rebuildByDate();
    notifyListeners();
  }
}
