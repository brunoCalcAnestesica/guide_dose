class Note {
  String id;
  String title;
  String content;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? archivedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static Note fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Sem título',
      content: json['content'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
      archivedAt: json['archived_at'] != null
          ? DateTime.tryParse(json['archived_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toSupabaseRow(String uid) => {
        'id': id,
        'user_id': uid,
        'title': title,
        'content': content,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Note.fromSupabaseRow(Map<String, dynamic> row) {
    return Note(
      id: row['id'] as String,
      title: row['title'] as String? ?? 'Sem título',
      content: row['content'] as String? ?? '',
      createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(row['updated_at'] as String? ?? '') ??
          DateTime.now(),
      archivedAt: row['archived_at'] != null
          ? DateTime.tryParse(row['archived_at'] as String? ?? '')
          : null,
    );
  }

  Map<String, dynamic> toDbRow(String uid) => {
        'id': id,
        'user_id': uid,
        'title': title,
        'content': content,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'sync_status': 'pending',
      };

  factory Note.fromDbRow(Map<String, dynamic> row) {
    return Note(
      id: row['id'] as String,
      title: row['title'] as String? ?? 'Sem título',
      content: row['content'] as String? ?? '',
      createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(row['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
