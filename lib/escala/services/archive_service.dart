import '../../storage_manager.dart';
import '../models/shift_report.dart';
import '../providers/blocked_day_provider.dart';
import '../providers/recurrence_provider.dart';
import '../providers/report_provider.dart';
import '../providers/shift_provider.dart';

/// Handles two distinct archival moments:
///   1. Report generation — runs when a month ends (creates/updates ShiftReport).
///   2. Calendar cleanup — removes data older than 3 complete months.
class ArchiveService {
  static const String _kLastReportMonth = 'archive_last_report_month';

  final ShiftProvider shiftProvider;
  final RecurrenceProvider recurrenceProvider;
  final ReportProvider reportProvider;
  final BlockedDayProvider? blockedDayProvider;
  final String userId;

  ArchiveService({
    required this.shiftProvider,
    required this.recurrenceProvider,
    required this.reportProvider,
    this.blockedDayProvider,
    required this.userId,
  });

  /// Should be called on app startup. Checks if the month changed and runs
  /// report generation + cleanup if needed.
  Future<void> checkAndRun() async {
    final now = DateTime.now();
    final currentKey = '${now.year}-${now.month}';
    final lastKey = StorageManager.instance.getString(_kLastReportMonth);

    if (lastKey == currentKey) return;

    await _generateMissingReports(now);
    await _cleanupOldData(now);

    await StorageManager.instance.setString(_kLastReportMonth, currentKey);
  }

  /// Generates reports for any past months that don't have one yet.
  Future<void> _generateMissingReports(DateTime now) async {
    final currentMonth = DateTime(now.year, now.month);

    // Generate reports for months from startDate backward up to a reasonable limit.
    // We only need to catch up for months that might have been missed
    // (e.g., app not opened for multiple months).
    for (int i = 1; i <= 12; i++) {
      final targetMonth = DateTime(currentMonth.year, currentMonth.month - i);
      final year = targetMonth.year;
      final month = targetMonth.month;

      if (!reportProvider.hasReport(year, month)) {
        await generateReport(year, month);
      }
    }
  }

  /// Generates (or regenerates) a report for a specific month by combining
  /// sporadic shifts and recurrence occurrences.
  Future<void> generateReport(int year, int month) async {
    final sporadicShifts = shiftProvider.getByMonth(year, month);
    final recurringShifts =
        recurrenceProvider.getOccurrencesForMonth(year, month);
    final allShifts = [...sporadicShifts, ...recurringShifts];

    if (allShifts.isEmpty) return;

    final details = <ShiftReportDetail>[];
    double totalHours = 0;
    double totalValue = 0;
    int paidCount = 0;
    double paidValue = 0;
    int pendingCount = 0;
    double pendingValue = 0;
    final byHospital = <String, int>{};
    final byType = <String, int>{};

    for (final s in allShifts) {
      totalHours += s.durationHours;
      totalValue += s.value;

      if (s.isCompleted) {
        paidCount++;
        paidValue += s.value;
      } else {
        pendingCount++;
        pendingValue += s.value;
      }

      byHospital[s.hospitalName] = (byHospital[s.hospitalName] ?? 0) + 1;
      byType[s.type] = (byType[s.type] ?? 0) + 1;

      final dateStr =
          '${s.date.year}-${s.date.month.toString().padLeft(2, '0')}-${s.date.day.toString().padLeft(2, '0')}';
      details.add(ShiftReportDetail(
        date: dateStr,
        hospital: s.hospitalName,
        type: s.type,
        start: s.startTime,
        end: s.endTime,
        hours: s.durationHours,
        value: s.value,
        paid: s.isCompleted,
      ));
    }

    final report = ShiftReport(
      userId: userId,
      year: year,
      month: month,
      totalHours: totalHours,
      totalValue: totalValue,
      shiftsCount: allShifts.length,
      paidCount: paidCount,
      paidValue: paidValue,
      pendingCount: pendingCount,
      pendingValue: pendingValue,
      byHospital: byHospital,
      byType: byType,
      details: details,
    );

    await reportProvider.saveReport(report);
  }

  /// Removes sporadic shifts and expired recurrence rules older than
  /// 3 complete months.
  Future<void> _cleanupOldData(DateTime now) async {
    final cutoff = DateTime(now.year, now.month - 3, 1);

    await shiftProvider.deleteShiftsBefore(cutoff);
    await recurrenceProvider.cleanupExpired(cutoff);
    await blockedDayProvider?.deleteBlockedDaysBefore(cutoff);
  }

  /// Called after CRUD on a past month that already has a report.
  /// Regenerates that month's report to reflect the change.
  Future<void> regenerateReportIfNeeded(int year, int month) async {
    if (reportProvider.hasReport(year, month)) {
      await generateReport(year, month);
    }
  }
}
