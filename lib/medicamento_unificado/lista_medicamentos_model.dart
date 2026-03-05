import 'dart:convert';

class ListaMedicamentosCustom {
  final String id;
  final String nome;
  final List<String> medicamentoIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  ListaMedicamentosCustom({
    required this.id,
    required this.nome,
    required this.medicamentoIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'medicamentoIds': medicamentoIds,
      };

  factory ListaMedicamentosCustom.fromJson(Map<String, dynamic> json) {
    return ListaMedicamentosCustom(
      id: json['id'] as String? ?? '',
      nome: json['nome'] as String? ?? '',
      medicamentoIds: (json['medicamentoIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  ListaMedicamentosCustom copyWith({
    String? id,
    String? nome,
    List<String>? medicamentoIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ListaMedicamentosCustom(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      medicamentoIds: medicamentoIds ?? List.from(this.medicamentoIds),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toDbRow(String uid) => {
        'id': id,
        'user_id': uid,
        'nome': nome,
        'medicamento_ids': jsonEncode(medicamentoIds),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'sync_status': 'pending',
      };

  factory ListaMedicamentosCustom.fromDbRow(Map<String, dynamic> row) {
    return ListaMedicamentosCustom(
      id: row['id'] as String,
      nome: row['nome'] as String? ?? '',
      medicamentoIds: _decodeIds(row['medicamento_ids']),
      createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(row['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toSupabaseRow(String uid) => {
        'id': id,
        'user_id': uid,
        'nome': nome,
        'medicamento_ids': medicamentoIds,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory ListaMedicamentosCustom.fromSupabaseRow(Map<String, dynamic> row) {
    return ListaMedicamentosCustom(
      id: row['id'] as String,
      nome: row['nome'] as String? ?? '',
      medicamentoIds: _decodeIds(row['medicamento_ids']),
      createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(row['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  static List<String> _decodeIds(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
    }
    if (value is String) {
      try {
        final decoded = jsonDecode(value) as List<dynamic>?;
        return decoded?.map((e) => e.toString()).toList() ?? [];
      } catch (_) {
        return [];
      }
    }
    return [];
  }
}
