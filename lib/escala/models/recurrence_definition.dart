import 'dart:convert';
import 'recurrence_rule.dart';

/// Represents a recurring shift rule stored in the database.
/// Unlike Shift (which is a single event), this defines a pattern
/// that generates virtual occurrences on the calendar.
class RecurrenceDefinition {
  String id;
  String hospitalName;
  DateTime startDate;
  String startTime;
  String endTime;
  double durationHours;
  double value;
  String type;
  String? informations;
  bool isAllDay;
  RecurrenceRule rule;

  /// When non-null, the series stops generating occurrences after this date.
  /// Set by "delete this and following" — the rule row is only physically
  /// removed once this date falls outside the 3-month calendar window.
  DateTime? endDate;

  /// Dates excluded from the series (single-occurrence CRUD).
  /// The recurrence pattern stays intact; these specific dates are simply
  /// skipped when generating virtual occurrences.
  List<DateTime> excludedDates;

  /// Dates within the series that have been marked as paid.
  List<DateTime> paidDates;

  DateTime createdAt;
  DateTime updatedAt;

  RecurrenceDefinition({
    required this.id,
    required this.hospitalName,
    required this.startDate,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.value,
    required this.type,
    this.informations,
    this.isAllDay = false,
    required this.rule,
    this.endDate,
    List<DateTime>? excludedDates,
    List<DateTime>? paidDates,
    required this.createdAt,
    required this.updatedAt,
  })  : excludedDates = excludedDates ?? [],
        paidDates = paidDates ?? [];

  RecurrenceDefinition copyWith({
    String? id,
    String? hospitalName,
    DateTime? startDate,
    String? startTime,
    String? endTime,
    double? durationHours,
    double? value,
    String? type,
    String? informations,
    bool? isAllDay,
    RecurrenceRule? rule,
    DateTime? endDate,
    List<DateTime>? excludedDates,
    List<DateTime>? paidDates,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurrenceDefinition(
      id: id ?? this.id,
      hospitalName: hospitalName ?? this.hospitalName,
      startDate: startDate ?? this.startDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationHours: durationHours ?? this.durationHours,
      value: value ?? this.value,
      type: type ?? this.type,
      informations: informations ?? this.informations,
      isAllDay: isAllDay ?? this.isAllDay,
      rule: rule ?? this.rule,
      endDate: endDate ?? this.endDate,
      excludedDates: excludedDates ?? List.of(this.excludedDates),
      paidDates: paidDates ?? List.of(this.paidDates),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isActive => endDate == null;

  static String _dateToIso(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime _parseDate(dynamic val) {
    if (val is String) return DateTime.parse(val);
    if (val is DateTime) return val;
    return DateTime.now();
  }

  /// Generates occurrences that fall within [rangeStart, rangeEnd],
  /// excluding any dates in [excludedDates].
  List<DateTime> getOccurrencesInRange(DateTime rangeStart, DateTime rangeEnd) {
    final effectiveEnd = endDate != null && endDate!.isBefore(rangeEnd)
        ? endDate!
        : rangeEnd;

    if (startDate.isAfter(effectiveEnd)) return [];

    final allDates = rule.generateOccurrencesInRange(startDate, rangeStart, effectiveEnd);
    if (excludedDates.isEmpty) return allDates;

    final excludedSet = excludedDates.map(_dateToIso).toSet();
    return allDates.where((d) => !excludedSet.contains(_dateToIso(d))).toList();
  }

  // -- SQLite serialization --

  Map<String, dynamic> toDbRow(String uid) => {
        'id': id,
        'user_id': uid,
        'hospital_name': hospitalName,
        'start_date': _dateToIso(startDate),
        'start_time': startTime,
        'end_time': endTime,
        'duration_hours': durationHours,
        'value': value,
        'type': type,
        'informations': informations?.isEmpty ?? true ? null : informations,
        'is_all_day': isAllDay ? 1 : 0,
        'recurrence_type': rule.type,
        'recurrence_interval': rule.interval,
        'recurrence_days_of_week':
            rule.daysOfWeek.isNotEmpty ? jsonEncode(rule.daysOfWeek) : null,
        'recurrence_end_type': rule.endType,
        'recurrence_end_date': rule.endDate != null ? _dateToIso(rule.endDate!) : null,
        'recurrence_end_count': rule.endCount,
        'recurrence_week_of_month': rule.weekOfMonth,
        'end_date': endDate != null ? _dateToIso(endDate!) : null,
        'excluded_dates': excludedDates.isNotEmpty
            ? jsonEncode(excludedDates.map(_dateToIso).toList())
            : null,
        'paid_dates': paidDates.isNotEmpty
            ? jsonEncode(paidDates.map(_dateToIso).toList())
            : null,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'sync_status': 'pending',
      };

  factory RecurrenceDefinition.fromDbRow(Map<String, dynamic> row) {
    List<int> daysOfWeek = [];
    final dowRaw = row['recurrence_days_of_week'];
    if (dowRaw != null && dowRaw is String && dowRaw.isNotEmpty) {
      daysOfWeek = List<int>.from(jsonDecode(dowRaw) as List);
    }

    final rule = RecurrenceRule(
      type: row['recurrence_type'] as String,
      interval: row['recurrence_interval'] as int? ?? 1,
      daysOfWeek: daysOfWeek,
      endType: row['recurrence_end_type'] as String? ?? 'never',
      endDate: row['recurrence_end_date'] != null
          ? _parseDate(row['recurrence_end_date'])
          : null,
      endCount: row['recurrence_end_count'] as int?,
      weekOfMonth: row['recurrence_week_of_month'] as int?,
    );

    List<DateTime> excluded = [];
    final exRaw = row['excluded_dates'];
    if (exRaw != null && exRaw is String && exRaw.isNotEmpty) {
      excluded = (jsonDecode(exRaw) as List).map((e) => DateTime.parse(e as String)).toList();
    }

    List<DateTime> paid = [];
    final paidRaw = row['paid_dates'];
    if (paidRaw != null && paidRaw is String && paidRaw.isNotEmpty) {
      paid = (jsonDecode(paidRaw) as List).map((e) => DateTime.parse(e as String)).toList();
    }

    return RecurrenceDefinition(
      id: row['id'] as String,
      hospitalName: row['hospital_name'] as String,
      startDate: _parseDate(row['start_date']),
      startTime: row['start_time'] as String,
      endTime: row['end_time'] as String,
      durationHours: (row['duration_hours'] as num).toDouble(),
      value: (row['value'] as num).toDouble(),
      type: row['type'] as String,
      informations: row['informations'] as String?,
      isAllDay: (row['is_all_day'] as int? ?? 0) == 1,
      rule: rule,
      endDate: row['end_date'] != null ? _parseDate(row['end_date']) : null,
      excludedDates: excluded,
      paidDates: paid,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }

  // -- Supabase serialization --

  Map<String, dynamic> toSupabaseRow(String uid) => {
        'id': id,
        'user_id': uid,
        'hospital_name': hospitalName,
        'start_date': _dateToIso(startDate),
        'start_time': startTime,
        'end_time': endTime,
        'duration_hours': durationHours,
        'value': value,
        'type': type,
        'informations': informations?.isEmpty ?? true ? null : informations,
        'is_all_day': isAllDay,
        'recurrence_rule': rule.toJson(),
        'end_date': endDate != null ? _dateToIso(endDate!) : null,
        'excluded_dates': excludedDates.map(_dateToIso).toList(),
        'paid_dates': paidDates.map(_dateToIso).toList(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory RecurrenceDefinition.fromSupabaseRow(Map<String, dynamic> row) {
    RecurrenceRule rule = RecurrenceRule();
    final rr = row['recurrence_rule'];
    if (rr != null && rr is Map) {
      rule = RecurrenceRule.fromJson(Map<String, dynamic>.from(rr));
    }

    List<DateTime> excluded = [];
    final exRaw = row['excluded_dates'];
    if (exRaw != null && exRaw is List) {
      excluded = exRaw.map((e) => DateTime.parse(e as String)).toList();
    }

    List<DateTime> paid = [];
    final paidRaw = row['paid_dates'];
    if (paidRaw != null && paidRaw is List) {
      paid = paidRaw.map((e) => DateTime.parse(e as String)).toList();
    }

    return RecurrenceDefinition(
      id: row['id'] as String,
      hospitalName: row['hospital_name'] as String,
      startDate: _parseDate(row['start_date']),
      startTime: row['start_time'] as String,
      endTime: row['end_time'] as String,
      durationHours: (row['duration_hours'] as num).toDouble(),
      value: (row['value'] as num).toDouble(),
      type: row['type'] as String,
      informations: row['informations'] as String?,
      isAllDay: row['is_all_day'] as bool? ?? false,
      rule: rule,
      endDate: row['end_date'] != null ? _parseDate(row['end_date']) : null,
      excludedDates: excluded,
      paidDates: paid,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: DateTime.parse(row['updated_at'] as String),
    );
  }
}
