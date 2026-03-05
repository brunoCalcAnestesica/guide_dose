import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/procedure.dart';
import '../services/widget_service.dart';

class ProcedureProvider extends ChangeNotifier {
  final Uuid _uuid = const Uuid();
  static const int _windowMonthsBefore = 6;
  static const int _windowMonthsAfter = 6;

  List<Procedure> _procedures = [];
  bool _isLoading = false;
  DateTime? _windowFrom;
  DateTime? _windowTo;
  Map<String, List<Procedure>> _byMonth = {};
  Map<String, List<Procedure>> _byDate = {};

  List<Procedure> get procedures => _procedures;
  bool get isLoading => _isLoading;
  DateTime? get windowFrom => _windowFrom;
  DateTime? get windowTo => _windowTo;

  void _rebuildIndexes() {
    _byMonth.clear();
    _byDate.clear();
    for (final p in _procedures) {
      final y = p.date.year;
      final m = p.date.month;
      final d = p.date.day;
      _byMonth.putIfAbsent('$y-$m', () => []).add(p);
      _byDate.putIfAbsent('$y-$m-$d', () => []).add(p);
    }
    for (final list in _byMonth.values) {
      list.sort((a, b) => a.date.compareTo(b.date));
    }
    for (final list in _byDate.values) {
      list.sort((a, b) => a.date.compareTo(b.date));
    }
  }

  void _notifyAndUpdateWidget() {
    notifyListeners();
    WidgetService.scheduleUpdate();
  }

  static DateTime _windowStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month - _windowMonthsBefore, 1);
  }

  static DateTime _windowEnd() {
    final now = DateTime.now();
    return DateTime(now.year, now.month + _windowMonthsAfter + 1, 0);
  }

  Future<void> loadProcedures() async {
    _isLoading = true;
    notifyListeners();

    _windowFrom = _windowStart();
    _windowTo = _windowEnd();
    _procedures.sort((a, b) => a.date.compareTo(b.date));
    _rebuildIndexes();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMoreIfNeeded(DateTime date) async {
    if (_windowFrom == null || _windowTo == null) return;
    final target = DateTime(date.year, date.month, date.day);
    if (!target.isBefore(_windowFrom!) && !target.isAfter(_windowTo!)) return;

    if (target.isBefore(_windowFrom!)) {
      _windowFrom = DateTime(target.year, target.month, 1);
    }
    if (target.isAfter(_windowTo!)) {
      _windowTo = DateTime(target.year, target.month + 1, 0);
    }
    notifyListeners();
  }

  Future<void> syncChanges() async {
    // placeholder for future backend sync
  }

  List<Procedure> getByDate(DateTime date) {
    final key = '${date.year}-${date.month}-${date.day}';
    final list = _byDate[key];
    return list != null ? List<Procedure>.from(list) : <Procedure>[];
  }

  List<Procedure> getByMonth(int year, int month) {
    final key = '$year-$month';
    final list = _byMonth[key];
    return list != null ? List<Procedure>.from(list) : <Procedure>[];
  }

  List<Procedure> getByDateRange(DateTime start, DateTime end) {
    final startNorm = DateTime(start.year, start.month, start.day);
    final endNorm = DateTime(end.year, end.month, end.day);
    return _procedures.where((p) {
      final d = DateTime(p.date.year, p.date.month, p.date.day);
      return (d.isAtSameMomentAs(startNorm) || d.isAfter(startNorm)) &&
          (d.isAtSameMomentAs(endNorm) || d.isBefore(endNorm));
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<Procedure> getByHospital(String hospitalName) {
    return _procedures.where((p) => p.hospitalName == hospitalName).toList();
  }

  double getTotalValueForMonth(int year, int month) {
    final monthProcs = getByMonth(year, month);
    return monthProcs.fold(0.0, (sum, p) => sum + p.value);
  }

  double getCompletedValueForMonth(int year, int month) {
    final monthProcs = getByMonth(year, month);
    return monthProcs
        .where((p) => p.isCompleted)
        .fold(0.0, (sum, p) => sum + p.value);
  }

  double getPendingValueForMonth(int year, int month) {
    final monthProcs = getByMonth(year, month);
    return monthProcs
        .where((p) => !p.isCompleted)
        .fold(0.0, (sum, p) => sum + p.value);
  }

  List<Procedure> getByYear(int year) {
    return _procedures.where((p) => p.date.year == year).toList();
  }

  double getTotalValueForYear(int year) {
    return getByYear(year).fold(0.0, (sum, p) => sum + p.value);
  }

  double getCompletedValueForYear(int year) {
    return getByYear(year)
        .where((p) => p.isCompleted)
        .fold(0.0, (sum, p) => sum + p.value);
  }

  double getPendingValueForYear(int year) {
    return getByYear(year)
        .where((p) => !p.isCompleted)
        .fold(0.0, (sum, p) => sum + p.value);
  }

  Set<DateTime> getDaysWithProcedures(int year, int month) {
    final monthProcs = getByMonth(year, month);
    return monthProcs
        .map((p) => DateTime(p.date.year, p.date.month, p.date.day))
        .toSet();
  }

  Future<void> addProcedure({
    required String hospitalName,
    required DateTime date,
    required String procedureType,
    String? procedureTypeId,
    required double value,
    bool isCompleted = false,
  }) async {
    final procedure = Procedure(
      id: _uuid.v4(),
      hospitalName: hospitalName,
      date: date,
      procedureType: procedureType,
      procedureTypeId: procedureTypeId,
      value: value,
      isCompleted: isCompleted,
      createdAt: DateTime.now(),
    );

    _procedures.add(procedure);
    _procedures.sort((a, b) => a.date.compareTo(b.date));
    _rebuildIndexes();
    _notifyAndUpdateWidget();
  }

  Future<void> updateProcedure(Procedure procedure) async {
    final index = _procedures.indexWhere((p) => p.id == procedure.id);
    if (index != -1) {
      _procedures[index] = procedure;
      _procedures.sort((a, b) => a.date.compareTo(b.date));
      _rebuildIndexes();
    }
    _notifyAndUpdateWidget();
  }

  Future<void> toggleCompleted(String id) async {
    final index = _procedures.indexWhere((p) => p.id == id);
    if (index != -1) {
      final updated = _procedures[index]
          .copyWith(isCompleted: !_procedures[index].isCompleted);
      _procedures[index] = updated;
      _rebuildIndexes();
      _notifyAndUpdateWidget();
    }
  }

  Future<void> deleteProcedure(String id) async {
    _procedures.removeWhere((p) => p.id == id);
    _rebuildIndexes();
    _notifyAndUpdateWidget();
  }
}
