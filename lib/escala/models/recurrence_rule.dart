class RecurrenceRule {
  static const int maxOccurrences = 999;
  static const int maxDaysAhead = 730;

  String type; // none, daily, weekly, monthly, monthlyWeekday, yearly, weekdays, custom
  int interval;
  List<int> daysOfWeek; // 1=seg, 2=ter, ..., 7=dom
  String endType; // never, date, count
  DateTime? endDate;
  int? endCount;
  int? weekOfMonth; // 1=primeiro, 2=segundo, ..., -1=ultimo (para monthlyWeekday)

  RecurrenceRule({
    this.type = 'none',
    this.interval = 1,
    this.daysOfWeek = const [],
    this.endType = 'never',
    this.endDate,
    this.endCount,
    this.weekOfMonth,
  });

  RecurrenceRule copyWith({
    String? type,
    int? interval,
    List<int>? daysOfWeek,
    String? endType,
    DateTime? endDate,
    int? endCount,
    int? weekOfMonth,
  }) {
    return RecurrenceRule(
      type: type ?? this.type,
      interval: interval ?? this.interval,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      endType: endType ?? this.endType,
      endDate: endDate ?? this.endDate,
      endCount: endCount ?? this.endCount,
      weekOfMonth: weekOfMonth ?? this.weekOfMonth,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'interval': interval,
        'daysOfWeek': daysOfWeek,
        'endType': endType,
        'endDate': endDate?.toIso8601String(),
        'endCount': endCount,
        'weekOfMonth': weekOfMonth,
      };

  factory RecurrenceRule.fromJson(Map<String, dynamic> json) => RecurrenceRule(
        type: json['type'] as String? ?? 'none',
        interval: json['interval'] as int? ?? 1,
        daysOfWeek: List<int>.from((json['daysOfWeek'] as List<dynamic>?) ?? []),
        endType: json['endType'] as String? ?? 'never',
        endDate: json['endDate'] != null
            ? DateTime.parse(json['endDate'] as String)
            : null,
        endCount: json['endCount'] as int?,
        weekOfMonth: json['weekOfMonth'] as int?,
      );

  bool get isNone => type == 'none';

  /// Generates occurrences starting from [startDate] that fall within
  /// [rangeStart, rangeEnd] inclusive.
  List<DateTime> generateOccurrencesInRange(
      DateTime startDate, DateTime rangeStart, DateTime rangeEnd) {
    final all = generateOccurrences(startDate, maxDateOverride: rangeEnd);
    return all
        .where((d) =>
            (d.isAfter(rangeStart) || _sameDay(d, rangeStart)) &&
            (d.isBefore(rangeEnd) || _sameDay(d, rangeEnd)))
        .toList();
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<DateTime> generateOccurrences(DateTime startDate, {DateTime? maxDateOverride}) {
    if (isNone) return [startDate];

    final List<DateTime> dates = [];
    final DateTime ruleMax = endType == 'date' && endDate != null
        ? endDate!
        : startDate.add(Duration(days: maxDaysAhead));
    final DateTime maxDate = maxDateOverride != null && maxDateOverride.isBefore(ruleMax)
        ? maxDateOverride
        : ruleMax;
    final int maxCount = endType == 'count' && endCount != null
        ? endCount!
        : maxOccurrences;

    switch (type) {
      case 'daily':
        _generateDaily(startDate, maxDate, maxCount, dates);
      case 'weekly':
        _generateWeekly(startDate, maxDate, maxCount, dates);
      case 'monthly':
        _generateMonthly(startDate, maxDate, maxCount, dates);
      case 'monthlyWeekday':
        _generateMonthlyWeekday(startDate, maxDate, maxCount, dates);
      case 'yearly':
        _generateYearly(startDate, maxDate, maxCount, dates);
      case 'weekdays':
        _generateWeekdays(startDate, maxDate, maxCount, dates);
      case 'custom':
        _generateCustom(startDate, maxDate, maxCount, dates);
      default:
        dates.add(startDate);
    }

    return dates;
  }

  void _generateDaily(
      DateTime start, DateTime maxDate, int maxCount, List<DateTime> dates) {
    DateTime current = start;
    while (current.isBefore(maxDate) || current.isAtSameMomentAs(maxDate)) {
      dates.add(current);
      if (dates.length >= maxCount) break;
      current = current.add(Duration(days: interval));
    }
  }

  void _generateWeekly(
      DateTime start, DateTime maxDate, int maxCount, List<DateTime> dates) {
    final int weekday = start.weekday;
    DateTime current = start;
    while (current.isBefore(maxDate) || current.isAtSameMomentAs(maxDate)) {
      if (current.weekday == weekday) {
        dates.add(current);
        if (dates.length >= maxCount) break;
      }
      current = current.add(Duration(days: 7 * interval));
    }
  }

  void _generateMonthly(
      DateTime start, DateTime maxDate, int maxCount, List<DateTime> dates) {
    DateTime current = start;
    while (current.isBefore(maxDate) || current.isAtSameMomentAs(maxDate)) {
      dates.add(current);
      if (dates.length >= maxCount) break;
      current = DateTime(
          current.year, current.month + interval, current.day);
    }
  }

  void _generateMonthlyWeekday(
      DateTime start, DateTime maxDate, int maxCount, List<DateTime> dates) {
    if (weekOfMonth == null || daysOfWeek.isEmpty) {
      dates.add(start);
      return;
    }

    final targetWeekday = daysOfWeek.first;
    int currentYear = start.year;
    int currentMonth = start.month;

    while (dates.length < maxCount) {
      final date = _getNthWeekdayOfMonth(
          currentYear, currentMonth, targetWeekday, weekOfMonth!);

      if (date != null) {
        if ((date.isAfter(start) || date.isAtSameMomentAs(start)) &&
            (date.isBefore(maxDate) || date.isAtSameMomentAs(maxDate))) {
          dates.add(date);
        }
        if (date.isAfter(maxDate)) break;
      }

      currentMonth += interval;
      if (currentMonth > 12) {
        currentYear += currentMonth ~/ 12;
        currentMonth = currentMonth % 12;
        if (currentMonth == 0) {
          currentMonth = 12;
          currentYear--;
        }
      }
    }
  }

  static DateTime? _getNthWeekdayOfMonth(
      int year, int month, int weekday, int n) {
    if (n == -1) {
      final lastDay = DateTime(year, month + 1, 0);
      DateTime current = lastDay;
      while (current.month == month) {
        if (current.weekday == weekday) return current;
        current = current.subtract(const Duration(days: 1));
      }
      return null;
    }

    int count = 0;
    for (int d = 1; d <= 31; d++) {
      final date = DateTime(year, month, d);
      if (date.month != month) break;
      if (date.weekday == weekday) {
        count++;
        if (count == n) return date;
      }
    }
    return null;
  }

  void _generateYearly(
      DateTime start, DateTime maxDate, int maxCount, List<DateTime> dates) {
    DateTime current = start;
    while (current.isBefore(maxDate) || current.isAtSameMomentAs(maxDate)) {
      dates.add(current);
      if (dates.length >= maxCount) break;
      current = DateTime(
          current.year + interval, current.month, current.day);
    }
  }

  void _generateWeekdays(
      DateTime start, DateTime maxDate, int maxCount, List<DateTime> dates) {
    DateTime current = start;
    while (current.isBefore(maxDate) || current.isAtSameMomentAs(maxDate)) {
      if (current.weekday >= 1 && current.weekday <= 5) {
        dates.add(current);
        if (dates.length >= maxCount) break;
      }
      current = current.add(const Duration(days: 1));
    }
  }

  void _generateCustom(
      DateTime start, DateTime maxDate, int maxCount, List<DateTime> dates) {
    if (daysOfWeek.isNotEmpty) {
      DateTime weekStart = start;
      while (weekStart.isBefore(maxDate) ||
          weekStart.isAtSameMomentAs(maxDate)) {
        DateTime monday =
            weekStart.subtract(Duration(days: weekStart.weekday - 1));
        for (final day in daysOfWeek) {
          final date = monday.add(Duration(days: day - 1));
          if ((date.isAfter(start) || date.isAtSameMomentAs(start)) &&
              (date.isBefore(maxDate) || date.isAtSameMomentAs(maxDate))) {
            if (!dates.any((d) =>
                d.year == date.year &&
                d.month == date.month &&
                d.day == date.day)) {
              dates.add(date);
              if (dates.length >= maxCount) return;
            }
          }
        }
        weekStart = weekStart.add(Duration(days: 7 * interval));
      }
    } else {
      _generateDaily(start, maxDate, maxCount, dates);
    }
  }
}
