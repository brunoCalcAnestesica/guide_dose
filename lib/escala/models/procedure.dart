class Procedure {
  String id;
  String hospitalName;
  DateTime date;
  String procedureType;
  String? procedureTypeId;
  double value;
  bool isCompleted;
  DateTime createdAt;

  Procedure({
    required this.id,
    required this.hospitalName,
    required this.date,
    required this.procedureType,
    this.procedureTypeId,
    required this.value,
    this.isCompleted = false,
    required this.createdAt,
  });

  Procedure copyWith({
    String? id,
    String? hospitalName,
    DateTime? date,
    String? procedureType,
    String? procedureTypeId,
    double? value,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Procedure(
      id: id ?? this.id,
      hospitalName: hospitalName ?? this.hospitalName,
      date: date ?? this.date,
      procedureType: procedureType ?? this.procedureType,
      procedureTypeId: procedureTypeId ?? this.procedureTypeId,
      value: value ?? this.value,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static String _dateToIso(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime _parseDate(dynamic val) {
    if (val is String) return DateTime.parse(val);
    return DateTime.fromMillisecondsSinceEpoch(
        (val as DateTime).millisecondsSinceEpoch);
  }

  Map<String, dynamic> toSupabaseRow(String uid) => {
        'id': id,
        'user_id': uid,
        'hospital_name': hospitalName,
        'date': _dateToIso(date),
        'procedure_type': procedureType,
        'procedure_type_id': procedureTypeId,
        'value': value,
        'is_completed': isCompleted,
        'created_at': createdAt.toIso8601String(),
      };

  factory Procedure.fromSupabaseRow(Map<String, dynamic> row) {
    return Procedure(
      id: row['id'] as String,
      hospitalName: row['hospital_name'] as String,
      date: _parseDate(row['date']),
      procedureType: row['procedure_type'] as String,
      procedureTypeId: row['procedure_type_id'] as String?,
      value: (row['value'] as num).toDouble(),
      isCompleted: row['is_completed'] as bool? ?? false,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}
