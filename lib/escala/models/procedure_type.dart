class ProcedureType {
  String id;
  String name;
  double defaultValue;
  DateTime createdAt;

  ProcedureType({
    required this.id,
    required this.name,
    required this.defaultValue,
    required this.createdAt,
  });

  ProcedureType copyWith({
    String? id,
    String? name,
    double? defaultValue,
    DateTime? createdAt,
  }) {
    return ProcedureType(
      id: id ?? this.id,
      name: name ?? this.name,
      defaultValue: defaultValue ?? this.defaultValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toSupabaseRow(String uid) => {
        'id': id,
        'user_id': uid,
        'name': name,
        'default_value': defaultValue,
        'created_at': createdAt.toIso8601String(),
      };

  factory ProcedureType.fromSupabaseRow(Map<String, dynamic> row) {
    return ProcedureType(
      id: row['id'] as String,
      name: row['name'] as String,
      defaultValue: (row['default_value'] as num).toDouble(),
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}
