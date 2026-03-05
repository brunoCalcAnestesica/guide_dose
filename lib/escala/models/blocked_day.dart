class BlockedDay {
  String id;
  DateTime date;
  String label;
  DateTime createdAt;
  DateTime updatedAt;

  BlockedDay({
    required this.id,
    required this.date,
    required this.label,
    required this.createdAt,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  static String _dateToIso(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime _parseDate(dynamic val) {
    if (val is String) return DateTime.parse(val);
    return DateTime.fromMillisecondsSinceEpoch(
        (val as DateTime).millisecondsSinceEpoch);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': _dateToIso(date),
        'label': label,
      };

  static BlockedDay fromJson(Map<String, dynamic> json) {
    final dateStr = json['date'] as String? ?? '';
    final parts = dateStr.split('-');
    final date = parts.length == 3
        ? DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          )
        : DateTime.now();
    return BlockedDay(
      id: json['id'] as String? ?? '',
      date: date,
      label: json['label'] as String? ?? 'Feriado',
      createdAt: DateTime.now(),
    );
  }

  // -- SQLite serialization --

  Map<String, dynamic> toDbRow(String uid) => {
        'id': id,
        'user_id': uid,
        'date': _dateToIso(date),
        'label': label,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'sync_status': 'pending',
      };

  factory BlockedDay.fromDbRow(Map<String, dynamic> row) {
    final createdAt = DateTime.parse(row['created_at'] as String);
    return BlockedDay(
      id: row['id'] as String,
      date: _parseDate(row['date']),
      label: row['label'] as String? ?? 'Feriado',
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
        'date': _dateToIso(date),
        'label': label,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory BlockedDay.fromSupabaseRow(Map<String, dynamic> row) {
    final createdAt = DateTime.parse(row['created_at'] as String);
    return BlockedDay(
      id: row['id'] as String,
      date: _parseDate(row['date']),
      label: row['label'] as String? ?? 'Feriado',
      createdAt: createdAt,
      updatedAt: row['updated_at'] != null
          ? DateTime.parse(row['updated_at'] as String)
          : createdAt,
    );
  }
}
