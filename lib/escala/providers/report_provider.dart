import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/daos/report_dao.dart';
import '../models/shift_report.dart';
import '../services/supabase_sync_service.dart';

class ReportProvider extends ChangeNotifier {
  final ReportDao _dao = ReportDao();
  final SupabaseSyncService _syncService = SupabaseSyncService();

  List<ShiftReport> _reports = [];
  bool _isLoading = false;

  List<ShiftReport> get reports => _reports;
  bool get isLoading => _isLoading;

  String get _userId =>
      Supabase.instance.client.auth.currentUser?.id ?? 'local';

  void _syncInBackground() {
    _syncService.pushPendingChanges().catchError((e) {
      debugPrint('Background sync error: $e');
      return 0;
    });
  }

  // ───────── Load ─────────

  Future<void> loadReports() async {
    _isLoading = true;
    notifyListeners();

    try {
      final rows = await _dao.getByUser(_userId);
      _reports = rows.map((r) => ShiftReport.fromDbRow(r)).toList();
    } catch (e) {
      debugPrint('ReportProvider.loadReports error: $e');
    }

    _reports.sort((a, b) {
      final yearCmp = b.year.compareTo(a.year);
      if (yearCmp != 0) return yearCmp;
      return b.month.compareTo(a.month);
    });

    _isLoading = false;
    notifyListeners();
  }

  // ───────── Query ─────────

  ShiftReport? getByMonth(int year, int month) {
    for (final r in _reports) {
      if (r.year == year && r.month == month) return r;
    }
    return null;
  }

  List<ShiftReport> getByYear(int year) {
    return _reports.where((r) => r.year == year).toList()
      ..sort((a, b) => a.month.compareTo(b.month));
  }

  List<int> getYears() {
    final years = _reports.map((r) => r.year).toSet().toList();
    years.sort((a, b) => b.compareTo(a));
    return years;
  }

  bool hasReport(int year, int month) {
    return _reports.any((r) => r.year == year && r.month == month);
  }

  double getTotalValueForYear(int year) {
    return getByYear(year).fold(0.0, (sum, r) => sum + r.totalValue);
  }

  double getTotalHoursForYear(int year) {
    return getByYear(year).fold(0.0, (sum, r) => sum + r.totalHours);
  }

  double getPaidValueForYear(int year) {
    return getByYear(year).fold(0.0, (sum, r) => sum + r.paidValue);
  }

  double getPendingValueForYear(int year) {
    return getByYear(year).fold(0.0, (sum, r) => sum + r.pendingValue);
  }

  // ───────── Write ─────────

  Future<void> saveReport(ShiftReport report) async {
    await _dao.insertOrReplace(report.toDbRow());
    final idx = _reports.indexWhere(
        (r) => r.year == report.year && r.month == report.month);
    if (idx != -1) {
      _reports[idx] = report;
    } else {
      _reports.add(report);
    }
    _reports.sort((a, b) {
      final yearCmp = b.year.compareTo(a.year);
      if (yearCmp != 0) return yearCmp;
      return b.month.compareTo(a.month);
    });
    notifyListeners();
    _syncInBackground();
  }
}
