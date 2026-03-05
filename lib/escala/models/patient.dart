import 'dart:convert';

class Antibiotic {
  DateTime startDate;
  String medication;
  bool isCompleted;

  Antibiotic({
    required this.startDate,
    required this.medication,
    this.isCompleted = false,
  });

  int get daysCount {
    return DateTime.now().difference(startDate).inDays + 1;
  }

  Map<String, dynamic> toJson() => {
        'start_date': startDate.toIso8601String(),
        'medication': medication,
        'is_completed': isCompleted,
      };

  factory Antibiotic.fromJson(Map<String, dynamic> json) => Antibiotic(
        startDate: DateTime.tryParse(json['start_date'] as String? ?? '') ??
            DateTime.now(),
        medication: json['medication'] as String? ?? '',
        isCompleted: json['is_completed'] as bool? ?? false,
      );
}

class LabExam {
  DateTime date;
  String name;
  String result;

  LabExam({
    required this.date,
    required this.name,
    required this.result,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'name': name,
        'result': result,
      };

  factory LabExam.fromJson(Map<String, dynamic> json) => LabExam(
        date:
            DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        name: json['name'] as String? ?? '',
        result: json['result'] as String? ?? '',
      );
}

class Patient {
  String id;
  String initials;
  double? age;
  String ageUnit;
  DateTime? admissionDate;
  String bed;
  String history;
  String devices;
  String diagnosis;
  String antibiotics;
  String vasoactiveDrugs;
  String exams;
  String pending;
  String observations;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? archivedAt;

  Patient({
    required this.id,
    required this.initials,
    this.age,
    this.ageUnit = 'anos',
    this.admissionDate,
    this.bed = '',
    this.history = '',
    this.devices = '',
    this.diagnosis = '',
    this.antibiotics = '',
    this.vasoactiveDrugs = '',
    this.exams = '',
    this.pending = '',
    this.observations = '',
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });

  int? get admissionDays {
    if (admissionDate == null) return null;
    return DateTime.now().difference(admissionDate!).inDays + 1;
  }

  String get ageDisplay {
    if (age == null) return '-';
    final v = age!;
    if (v == v.toInt().toDouble()) {
      return '${v.toInt()} $ageUnit';
    }
    return '${v.toStringAsFixed(1)} $ageUnit';
  }

  static List<Antibiotic> _parseAntibiotics(dynamic val) {
    if (val == null) return [];
    List<dynamic> list;
    if (val is String) {
      if (val.isEmpty || val == '[]') return [];
      list = jsonDecode(val) as List<dynamic>;
    } else {
      list = val as List<dynamic>;
    }
    return list
        .map((e) => Antibiotic.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static List<LabExam> _parseExams(dynamic val) {
    if (val == null) return [];
    List<dynamic> list;
    if (val is String) {
      if (val.isEmpty || val == '[]') return [];
      list = jsonDecode(val) as List<dynamic>;
    } else {
      list = val as List<dynamic>;
    }
    return list
        .map((e) => LabExam.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  static String _antibioticsToText(dynamic val) {
    if (val == null) return '';
    if (val is String) {
      final s = val.trim();
      if (s.isEmpty) return '';
      if (s.startsWith('[')) {
        try {
          final list = _parseAntibiotics(val);
          return list
              .map((a) =>
                  '${a.medication} (${_dateToIso(a.startDate)})')
              .join('\n');
        } catch (_) {
          return s;
        }
      }
      return s;
    }
    if (val is List) {
      return val
          .map((e) {
            try {
              final a = Antibiotic.fromJson(Map<String, dynamic>.from(e as Map));
              return '${a.medication} (${_dateToIso(a.startDate)})';
            } catch (_) {
              return '';
            }
          })
          .where((s) => s.isNotEmpty)
          .join('\n');
    }
    return '';
  }

  static String _examsToText(dynamic val) {
    if (val == null) return '';
    if (val is String) {
      final s = val.trim();
      if (s.isEmpty) return '';
      if (s.startsWith('[')) {
        try {
          final list = _parseExams(val);
          return list
              .map((e) =>
                  '${e.name} - ${e.result} (${_dateToIso(e.date)})')
              .join('\n');
        } catch (_) {
          return s;
        }
      }
      return s;
    }
    if (val is List) {
      return val
          .map((e) {
            try {
              final ex = LabExam.fromJson(Map<String, dynamic>.from(e as Map));
              return '${ex.name} - ${ex.result} (${_dateToIso(ex.date)})';
            } catch (_) {
              return '';
            }
          })
          .where((s) => s.isNotEmpty)
          .join('\n');
    }
    return '';
  }

  static String _dateToIso(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'initials': initials,
        'age': age,
        'age_unit': ageUnit,
        'admission_date': admissionDate != null ? _dateToIso(admissionDate!) : null,
        'bed': bed,
        'history': history,
        'devices': devices,
        'diagnosis': diagnosis,
        'antibiotics': antibiotics,
        'vasoactive_drugs': vasoactiveDrugs,
        'exams': exams,
        'pending': pending,
        'observations': observations,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static Patient fromJson(Map<String, dynamic> json) => Patient(
        id: json['id'] as String? ?? '',
        initials: json['initials'] as String? ?? '',
        age: (json['age'] as num?)?.toDouble(),
        ageUnit: json['age_unit'] as String? ?? 'anos',
        admissionDate: json['admission_date'] != null
            ? DateTime.tryParse(json['admission_date'] as String)
            : null,
        bed: json['bed'] as String? ?? '',
        history: json['history'] as String? ?? '',
        devices: json['devices'] as String? ?? '',
        diagnosis: json['diagnosis'] as String? ?? '',
        antibiotics: _antibioticsToText(json['antibiotics']),
        vasoactiveDrugs: json['vasoactive_drugs'] as String? ?? '',
        exams: _examsToText(json['exams']),
        pending: json['pending'] as String? ?? '',
        observations: json['observations'] as String? ?? '',
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
        updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
            DateTime.now(),
        archivedAt: json['archived_at'] != null
            ? DateTime.tryParse(json['archived_at'] as String)
            : null,
      );

  Map<String, dynamic> toSupabaseRow(String uid) => {
        'id': id,
        'user_id': uid,
        'initials': initials,
        'age': age,
        'age_unit': ageUnit,
        'admission_date':
            admissionDate != null ? _dateToIso(admissionDate!) : null,
        'bed': bed,
        'history': history,
        'devices': devices,
        'diagnosis': diagnosis,
        'antibiotics': antibiotics,
        'vasoactive_drugs': vasoactiveDrugs,
        'exams': exams,
        'pending': pending,
        'observations': observations,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  factory Patient.fromSupabaseRow(Map<String, dynamic> row) => Patient(
        id: row['id'] as String,
        initials: row['initials'] as String? ?? '',
        age: (row['age'] as num?)?.toDouble(),
        ageUnit: row['age_unit'] as String? ?? 'anos',
        admissionDate: row['admission_date'] != null
            ? DateTime.tryParse(row['admission_date'] as String)
            : null,
        bed: row['bed'] as String? ?? '',
        history: row['history'] as String? ?? '',
        devices: row['devices'] as String? ?? '',
        diagnosis: row['diagnosis'] as String? ?? '',
        antibiotics: _antibioticsToText(row['antibiotics']),
        vasoactiveDrugs: row['vasoactive_drugs'] as String? ?? '',
        exams: _examsToText(row['exams']),
        pending: row['pending'] as String? ?? '',
        observations: row['observations'] as String? ?? '',
        createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ??
            DateTime.now(),
        updatedAt: DateTime.tryParse(row['updated_at'] as String? ?? '') ??
            DateTime.now(),
        archivedAt: row['archived_at'] != null
            ? DateTime.tryParse(row['archived_at'] as String? ?? '')
            : null,
      );

  Map<String, dynamic> toDbRow(String uid) => {
        'id': id,
        'user_id': uid,
        'initials': initials,
        'age': age,
        'age_unit': ageUnit,
        'admission_date':
            admissionDate != null ? _dateToIso(admissionDate!) : null,
        'bed': bed,
        'history': history,
        'devices': devices,
        'diagnosis': diagnosis,
        'antibiotics': antibiotics,
        'vasoactive_drugs': vasoactiveDrugs,
        'exams': exams,
        'pending': pending,
        'observations': observations,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'sync_status': 'pending',
      };

  factory Patient.fromDbRow(Map<String, dynamic> row) => Patient(
        id: row['id'] as String,
        initials: row['initials'] as String? ?? '',
        age: (row['age'] as num?)?.toDouble(),
        ageUnit: row['age_unit'] as String? ?? 'anos',
        admissionDate: row['admission_date'] != null
            ? DateTime.tryParse(row['admission_date'] as String)
            : null,
        bed: row['bed'] as String? ?? '',
        history: row['history'] as String? ?? '',
        devices: row['devices'] as String? ?? '',
        diagnosis: row['diagnosis'] as String? ?? '',
        antibiotics: row['antibiotics'] as String? ?? '',
        vasoactiveDrugs: row['vasoactive_drugs'] as String? ?? '',
        exams: row['exams'] as String? ?? '',
        pending: row['pending'] as String? ?? '',
        observations: row['observations'] as String? ?? '',
        createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ??
            DateTime.now(),
        updatedAt: DateTime.tryParse(row['updated_at'] as String? ?? '') ??
            DateTime.now(),
      );
}
