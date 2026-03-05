/// Represents a single (non-recurring) shift event.
/// Recurring shifts are managed via [RecurrenceDefinition].
class Shift {
  String id;
  String hospitalName;
  DateTime date;
  String startTime;
  String endTime;
  double durationHours;
  double value;
  String type;
  String? informations;
  bool isAllDay;
  bool isCompleted;
  DateTime createdAt;
  DateTime updatedAt;

  /// When non-null, this shift was generated from a [RecurrenceDefinition].
  /// It is NOT persisted — used only at runtime for display purposes.
  String? sourceRecurrenceId;

  Shift({
    required this.id,
    required this.hospitalName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.durationHours,
    required this.value,
    required this.type,
    this.informations,
    this.isAllDay = false,
    this.isCompleted = false,
    required this.createdAt,
    DateTime? updatedAt,
    this.sourceRecurrenceId,
  }) : updatedAt = updatedAt ?? createdAt;

  bool get isFromRecurrence => sourceRecurrenceId != null;

  Shift copyWith({
    String? id,
    String? hospitalName,
    DateTime? date,
    String? startTime,
    String? endTime,
    double? durationHours,
    double? value,
    String? type,
    String? informations,
    bool? isAllDay,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? sourceRecurrenceId,
  }) {
    return Shift(
      id: id ?? this.id,
      hospitalName: hospitalName ?? this.hospitalName,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationHours: durationHours ?? this.durationHours,
      value: value ?? this.value,
      type: type ?? this.type,
      informations: informations ?? this.informations,
      isAllDay: isAllDay ?? this.isAllDay,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sourceRecurrenceId: sourceRecurrenceId ?? this.sourceRecurrenceId,
    );
  }

  static String _dateToIso(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime _parseDate(dynamic val) {
    if (val is String) return DateTime.parse(val);
    return DateTime.fromMillisecondsSinceEpoch(
        (val as DateTime).millisecondsSinceEpoch);
  }

  // -- SQLite serialization --

  Map<String, dynamic> toDbRow(String uid) => {
        'id': id,
        'user_id': uid,
        'hospital_name': hospitalName,
        'date': _dateToIso(date),
        'start_time': startTime,
        'end_time': endTime,
        'duration_hours': durationHours,
        'value': value,
        'type': type,
        'informations': informations?.isEmpty ?? true ? null : informations,
        'is_all_day': isAllDay ? 1 : 0,
        'is_completed': isCompleted ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'sync_status': 'pending',
      };

  factory Shift.fromDbRow(Map<String, dynamic> row) {
    final createdAt = DateTime.parse(row['created_at'] as String);
    return Shift(
      id: row['id'] as String,
      hospitalName: row['hospital_name'] as String,
      date: _parseDate(row['date']),
      startTime: row['start_time'] as String,
      endTime: row['end_time'] as String,
      durationHours: (row['duration_hours'] as num).toDouble(),
      value: (row['value'] as num).toDouble(),
      type: row['type'] as String,
      informations: row['informations'] as String?,
      isAllDay: (row['is_all_day'] as int? ?? 0) == 1,
      isCompleted: (row['is_completed'] as int? ?? 0) == 1,
      createdAt: createdAt,
      updatedAt: row['updated_at'] != null
          ? DateTime.parse(row['updated_at'] as String)
          : createdAt,
    );
  }

  // -- Supabase serialization --

  Map<String, dynamic> toSupabaseRow(String uid) => {
        'id': id,
        'user_id': uid,
        'hospital_name': hospitalName,
        'date': _dateToIso(date),
        'start_time': startTime,
        'end_time': endTime,
        'duration_hours': durationHours,
        'value': value,
        'type': type,
        'informacoes': informations?.isEmpty ?? true ? null : informations,
        'is_all_day': isAllDay,
        'is_completed': isCompleted,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Shift.fromSupabaseRow(Map<String, dynamic> row) {
    final createdAt = DateTime.parse(row['created_at'] as String);
    return Shift(
      id: row['id'] as String,
      hospitalName: row['hospital_name'] as String,
      date: _parseDate(row['date']),
      startTime: row['start_time'] as String,
      endTime: row['end_time'] as String,
      durationHours: (row['duration_hours'] as num).toDouble(),
      value: (row['value'] as num).toDouble(),
      type: row['type'] as String,
      informations: row['informacoes'] as String?,
      isAllDay: row['is_all_day'] as bool? ?? false,
      isCompleted: row['is_completed'] as bool? ?? false,
      createdAt: createdAt,
      updatedAt: row['updated_at'] != null
          ? DateTime.parse(row['updated_at'] as String)
          : createdAt,
    );
  }
}
