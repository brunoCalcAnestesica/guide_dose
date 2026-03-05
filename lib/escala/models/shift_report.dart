import 'dart:convert';

class ShiftReportDetail {
  final String date;
  final String hospital;
  final String type;
  final String start;
  final String end;
  final double hours;
  final double value;
  final bool paid;

  ShiftReportDetail({
    required this.date,
    required this.hospital,
    required this.type,
    required this.start,
    required this.end,
    required this.hours,
    required this.value,
    required this.paid,
  });

  Map<String, dynamic> toJson() => {
        'date': date,
        'hospital': hospital,
        'type': type,
        'start': start,
        'end': end,
        'hours': hours,
        'value': value,
        'paid': paid,
      };

  factory ShiftReportDetail.fromJson(Map<String, dynamic> json) =>
      ShiftReportDetail(
        date: json['date'] as String? ?? '',
        hospital: json['hospital'] as String? ?? '',
        type: json['type'] as String? ?? '',
        start: json['start'] as String? ?? '',
        end: json['end'] as String? ?? '',
        hours: (json['hours'] as num?)?.toDouble() ?? 0,
        value: (json['value'] as num?)?.toDouble() ?? 0,
        paid: json['paid'] as bool? ?? false,
      );
}

class ShiftReport {
  final String userId;
  final int year;
  final int month;
  double totalHours;
  double totalValue;
  int shiftsCount;
  int paidCount;
  double paidValue;
  int pendingCount;
  double pendingValue;
  Map<String, int> byHospital;
  Map<String, int> byType;
  List<ShiftReportDetail> details;
  DateTime createdAt;
  DateTime updatedAt;

  ShiftReport({
    required this.userId,
    required this.year,
    required this.month,
    this.totalHours = 0,
    this.totalValue = 0,
    this.shiftsCount = 0,
    this.paidCount = 0,
    this.paidValue = 0,
    this.pendingCount = 0,
    this.pendingValue = 0,
    Map<String, int>? byHospital,
    Map<String, int>? byType,
    List<ShiftReportDetail>? details,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : byHospital = byHospital ?? {},
        byType = byType ?? {},
        details = details ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Chave composta usada como "id" no LocalDatabaseService.
  String get id => '${year}_$month';

  bool get isComplete => pendingCount == 0;

  Map<String, dynamic> toSupabaseRow() => {
        'user_id': userId,
        'year': year,
        'month': month,
        'total_hours': totalHours,
        'total_value': totalValue,
        'shifts_count': shiftsCount,
        'paid_count': paidCount,
        'paid_value': paidValue,
        'pending_count': pendingCount,
        'pending_value': pendingValue,
        'by_hospital': byHospital,
        'by_type': byType,
        'details': details.map((d) => d.toJson()).toList(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

  /// Formato para armazenamento local (inclui campo `id` sintetico).
  Map<String, dynamic> toLocalRow() => {
        'id': id,
        ...toSupabaseRow(),
      };

  factory ShiftReport.fromSupabaseRow(Map<String, dynamic> row) {
    final detailsList = (row['details'] as List<dynamic>?)
            ?.map((d) =>
                ShiftReportDetail.fromJson(Map<String, dynamic>.from(d as Map)))
            .toList() ??
        [];
    final byHospitalRaw = row['by_hospital'] as Map<dynamic, dynamic>?;
    final byTypeRaw = row['by_type'] as Map<dynamic, dynamic>?;

    return ShiftReport(
      userId: row['user_id'] as String,
      year: row['year'] as int,
      month: row['month'] as int,
      totalHours: (row['total_hours'] as num?)?.toDouble() ?? 0,
      totalValue: (row['total_value'] as num?)?.toDouble() ?? 0,
      shiftsCount: row['shifts_count'] as int? ?? 0,
      paidCount: row['paid_count'] as int? ?? 0,
      paidValue: (row['paid_value'] as num?)?.toDouble() ?? 0,
      pendingCount: row['pending_count'] as int? ?? 0,
      pendingValue: (row['pending_value'] as num?)?.toDouble() ?? 0,
      byHospital: byHospitalRaw?.map((k, v) => MapEntry(k.toString(), (v as num).toInt())) ?? {},
      byType: byTypeRaw?.map((k, v) => MapEntry(k.toString(), (v as num).toInt())) ?? {},
      details: detailsList,
      createdAt: row['created_at'] != null ? DateTime.parse(row['created_at'] as String) : DateTime.now(),
      updatedAt: row['updated_at'] != null ? DateTime.parse(row['updated_at'] as String) : DateTime.now(),
    );
  }

  factory ShiftReport.fromLocalRow(Map<String, dynamic> row) =>
      ShiftReport.fromSupabaseRow(row);

  // -- SQLite serialization (JSON fields stored as TEXT) --

  Map<String, dynamic> toDbRow() => {
        'id': id,
        'user_id': userId,
        'year': year,
        'month': month,
        'total_hours': totalHours,
        'total_value': totalValue,
        'shifts_count': shiftsCount,
        'paid_count': paidCount,
        'paid_value': paidValue,
        'pending_count': pendingCount,
        'pending_value': pendingValue,
        'by_hospital': jsonEncode(byHospital),
        'by_type': jsonEncode(byType),
        'details': jsonEncode(details.map((d) => d.toJson()).toList()),
        'created_at': createdAt.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'sync_status': 'pending',
      };

  factory ShiftReport.fromDbRow(Map<String, dynamic> row) {
    List<ShiftReportDetail> detailsList = [];
    final detailsRaw = row['details'];
    if (detailsRaw is String && detailsRaw.isNotEmpty) {
      final parsed = jsonDecode(detailsRaw) as List<dynamic>;
      detailsList = parsed
          .map((d) => ShiftReportDetail.fromJson(Map<String, dynamic>.from(d as Map)))
          .toList();
    }

    Map<String, int> byHospital = {};
    final bhRaw = row['by_hospital'];
    if (bhRaw is String && bhRaw.isNotEmpty) {
      final parsed = jsonDecode(bhRaw) as Map<String, dynamic>;
      byHospital = parsed.map((k, v) => MapEntry(k, (v as num).toInt()));
    }

    Map<String, int> byType = {};
    final btRaw = row['by_type'];
    if (btRaw is String && btRaw.isNotEmpty) {
      final parsed = jsonDecode(btRaw) as Map<String, dynamic>;
      byType = parsed.map((k, v) => MapEntry(k, (v as num).toInt()));
    }

    return ShiftReport(
      userId: row['user_id'] as String,
      year: row['year'] as int,
      month: row['month'] as int,
      totalHours: (row['total_hours'] as num?)?.toDouble() ?? 0,
      totalValue: (row['total_value'] as num?)?.toDouble() ?? 0,
      shiftsCount: row['shifts_count'] as int? ?? 0,
      paidCount: row['paid_count'] as int? ?? 0,
      paidValue: (row['paid_value'] as num?)?.toDouble() ?? 0,
      pendingCount: row['pending_count'] as int? ?? 0,
      pendingValue: (row['pending_value'] as num?)?.toDouble() ?? 0,
      byHospital: byHospital,
      byType: byType,
      details: detailsList,
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at'] as String)
          : DateTime.now(),
      updatedAt: row['updated_at'] != null
          ? DateTime.parse(row['updated_at'] as String)
          : DateTime.now(),
    );
  }
}
