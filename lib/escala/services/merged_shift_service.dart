import '../models/shift.dart';
import '../providers/recurrence_provider.dart';
import '../providers/shift_provider.dart';

/// Combines sporadic shifts from [ShiftProvider] with virtual occurrences
/// from [RecurrenceProvider] to produce a unified view for the calendar.
class MergedShiftService {
  final ShiftProvider shiftProvider;
  final RecurrenceProvider recurrenceProvider;

  MergedShiftService({
    required this.shiftProvider,
    required this.recurrenceProvider,
  });

  List<Shift> getByDate(DateTime date) {
    final sporadic = shiftProvider.getByDate(date);
    final recurring = recurrenceProvider.getOccurrencesForDate(date);
    return _merge(sporadic, recurring);
  }

  List<Shift> getByMonth(int year, int month) {
    final sporadic = shiftProvider.getByMonth(year, month);
    final recurring = recurrenceProvider.getOccurrencesForMonth(year, month);
    return _merge(sporadic, recurring);
  }

  List<Shift> getByDateRange(DateTime start, DateTime end) {
    final sporadic = shiftProvider.getByDateRange(start, end);
    final recurring = recurrenceProvider.getOccurrencesForRange(start, end);
    return _merge(sporadic, recurring);
  }

  double getTotalValueForMonth(int year, int month) {
    return getByMonth(year, month).fold(0.0, (sum, s) => sum + s.value);
  }

  double getTotalHoursForMonth(int year, int month) {
    return getByMonth(year, month).fold(0.0, (sum, s) => sum + s.durationHours);
  }

  Set<DateTime> getDaysWithShifts(int year, int month) {
    return getByMonth(year, month)
        .map((s) => DateTime(s.date.year, s.date.month, s.date.day))
        .toSet();
  }

  List<Shift> _merge(List<Shift> sporadic, List<Shift> recurring) {
    final all = [...sporadic, ...recurring];
    all.sort((a, b) {
      final dc = a.date.compareTo(b.date);
      if (dc != 0) return dc;
      return a.startTime.compareTo(b.startTime);
    });
    return all;
  }
}
